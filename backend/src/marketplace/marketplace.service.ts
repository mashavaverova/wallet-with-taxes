import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Listing } from './entities/listing.entity';
import { Trade } from './entities/trade.entity';
import { ListItemDto } from './dto/list-item.dto';
import { TradeDto } from './dto/trade.dto';
import { JwtUser } from '../auth/jwt-user.interface';
import { GetListingsQueryDto } from './dto/get-listings-query.dto';
import { ethers } from 'ethers';
import marketplaceJson from '../shared/constants/abis/Marketplace.json';
import erc1155Json from '../shared/constants/abis/ERC1155.json';
import feeDistributorJson from '../shared/constants/abis/FeeDistributor.json';
import { TaxService } from '../tax/tax.service';

const MARKETPLACE_ADDRESS = process.env.MARKETPLACE_ADDRESS!;
const RPC_URL = process.env.RPC_URL!;
//const RELAYER_PK = process.env.RELAYER_PRIVATE_KEY!; now its hardcoded as signer from anvil

const FEE_DISTRIBUTOR_ADDRESS = process.env.FEE_DISTRIBUTOR_ADDRESS!;

const provider = new ethers.JsonRpcProvider(RPC_URL);
const signer = new ethers.Wallet(
  '0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6',
  provider,
);

const marketplaceAbi: ethers.InterfaceAbi =
  marketplaceJson as ethers.InterfaceAbi;
const erc1155Abi: ethers.InterfaceAbi = erc1155Json as ethers.InterfaceAbi;
const feeDistributorAbi: ethers.InterfaceAbi =
  feeDistributorJson as ethers.InterfaceAbi;

@Injectable()
export class MarketplaceService {
  constructor(
    @InjectRepository(Listing)
    private readonly listingRepo: Repository<Listing>,

    @InjectRepository(Trade)
    private readonly tradeRepo: Repository<Trade>,
    private readonly taxService: TaxService,
  ) {}

  async listItem(dto: ListItemDto, user: JwtUser) {
    const listing = this.listingRepo.create({
      sellerId: user.id,
      tokenAddress: dto.tokenAddress,
      tokenId: dto.tokenId,
      amount: dto.amount,
      pricePerUnit: dto.pricePerUnit,
    });
    await this.listingRepo.save(listing);

    // 🔁 Transfer NFT to marketplace
    const nftContract = new ethers.Contract(
      dto.tokenAddress,
      erc1155Abi,
      signer,
    );
    await nftContract.safeTransferFrom(
      user.walletAddress,
      MARKETPLACE_ADDRESS,
      dto.tokenId,
      dto.amount,
      '0x',
    );

    // 📦 List on-chain
    const marketplace = new ethers.Contract(
      MARKETPLACE_ADDRESS,
      marketplaceAbi,
      signer,
    );
    await marketplace.list(
      dto.tokenAddress,
      dto.tokenId,
      dto.amount,
      dto.pricePerUnit,
    );

    return listing;
    await this.taxService.logEvent({
      type: 'acquisition',
      userAddress: user.walletAddress,
      assetAddress: dto.tokenAddress,
      tokenId: dto.tokenId,
      amount: dto.amount,
      priceUSD: dto.pricePerUnit,
    });
  }

  async executeTrade(dto: TradeDto, user: JwtUser) {
    const listing = await this.listingRepo.findOneByOrFail({
      id: dto.listingId,
    });
    const totalPrice = listing.pricePerUnit * dto.amount;
    const fee = Math.min(totalPrice * 0.05, 100);

    const trade = this.tradeRepo.create({
      buyerId: user.id,
      sellerId: listing.sellerId,
      listingId: listing.id,
      amount: dto.amount,
      totalPrice,
      feeUSD: fee,
      status: 'pending',
    });
    await this.tradeRepo.save(trade);

    const marketplace = new ethers.Contract(
      MARKETPLACE_ADDRESS,
      marketplaceAbi,
      signer,
    );
    await marketplace.buy(dto.listingId, dto.amount);

    const feeDistributor = new ethers.Contract(
      FEE_DISTRIBUTOR_ADDRESS,
      feeDistributorAbi,
      signer,
    );
    await feeDistributor.distribute(fee);

    listing.amount -= dto.amount;
    if (listing.amount <= 0) {
      listing.status = 'sold';
    }
    await this.listingRepo.save(listing);

    trade.status = 'confirmed';
    await this.tradeRepo.save(trade);

    //  Tax logging (inserted here)
    await this.taxService.logEvent({
      type: 'disposal',
      userAddress: user.walletAddress,
      assetAddress: listing.tokenAddress,
      tokenId: listing.tokenId,
      amount: dto.amount,
      feeUSD: fee,
    });

    return trade;
  }

  async getListings(query: GetListingsQueryDto) {
    const where: Partial<Listing> = {};

    if (query.status) {
      where.status = query.status;
    }

    if (query.tokenId) {
      where.tokenId = Number(query.tokenId);
    }

    return this.listingRepo.find({ where });
  }
}
