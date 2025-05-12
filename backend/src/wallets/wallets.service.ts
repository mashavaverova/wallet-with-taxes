import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Wallet } from './wallet.entity';

@Injectable()
export class WalletsService {
  constructor(
    @InjectRepository(Wallet)
    private readonly walletRepo: Repository<Wallet>,
  ) {}

  async registerWallet(owner: string, address: string) {
    const wallet = this.walletRepo.create({ owner, address });
    return this.walletRepo.save(wallet);
  }

  async getWalletByOwner(owner: string) {
    return this.walletRepo.findOne({ where: { owner } });
  }
  getBalance(address: string) {
    // Mocked ETH balance response
    return {
      address,
      balance: '0.42 ETH',
    };
  }
  getAssets(address: string) {
    // Mocked token holdings response
    return {
      address,
      assets: [
        { name: 'TIX', symbol: 'TIX', balance: 500 },
        { name: 'USDC', symbol: 'USDC', balance: 1250 },
      ],
    };
  }

  getAssetDetail(address: string, tokenId: string) {
    // For PoC: return mock data
    return {
      tokenId,
      owner: address,
      type: 'ERC721',
      name: 'Genesis NFT #' + tokenId,
      image: `https://example.com/images/${tokenId}.png`,
      description: 'A unique Genesis NFT',
    };
  }
}
