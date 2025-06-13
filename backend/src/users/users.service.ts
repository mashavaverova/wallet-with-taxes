import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
import * as bcrypt from 'bcryptjs';
import { ethers } from 'ethers';
import * as crypto from 'crypto';
import GenesisWalletFactoryAbiJson from '../shared/constants/abis/GenesisWalletFactory.json';
import { JwtService } from '@nestjs/jwt';
import type { InterfaceAbi } from 'ethers';
import {
  ContractTransactionResponse,
  ContractTransactionReceipt,
} from 'ethers';
import console from 'console';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async signup(email: string, password: string) {
    const existingUser = await this.userRepository.findOne({
      where: { email },
    });
    if (existingUser) throw new Error('User already exists');

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);
    const wallet = ethers.Wallet.createRandom();

    const encryptionKey = process.env.ENCRYPTION_KEY;
    const encryptionIv = process.env.ENCRYPTION_IV;
    if (!encryptionKey || !encryptionIv) {
      throw new Error('Missing ENCRYPTION_KEY or ENCRYPTION_IV');
    }

    const cipher = crypto.createCipheriv(
      'aes-256-cbc',
      Buffer.from(encryptionKey, 'utf8'),
      Buffer.from(encryptionIv, 'utf8'),
    );
    const encryptedPrivateKey =
      cipher.update(wallet.privateKey, 'utf8', 'hex') + cipher.final('hex');

    const rpcUrl = process.env.RPC_URL;
    const factoryAddress = process.env.FACTORY_ADDRESS;
    const deployerKey = process.env.DEPLOYER_PRIVATE_KEY;
    if (!rpcUrl || !factoryAddress || !deployerKey) {
      throw new Error('Missing blockchain environment variables');
    }

    console.log('deployerKey:', deployerKey);
    console.log('RPC URL:', process.env.RPC_URL);
    console.log('Deployer Key:', process.env.DEPLOYER_PRIVATE_KEY);

    const provider = new ethers.JsonRpcProvider(rpcUrl);
    const deployer = new ethers.Wallet(deployerKey, provider);
    const factory = new ethers.Contract(
      factoryAddress,
      GenesisWalletFactoryAbiJson as InterfaceAbi,
      deployer,
    );

    const tx = (await factory.createWallet(
      wallet.address,
    )) as ContractTransactionResponse;
    const receipt = await tx.wait();
    if (!receipt || receipt.status !== 1) {
      throw new Error('Wallet creation failed on-chain');
    }

    const user = this.userRepository.create({
      email,
      passwordHash,
      custodyMode: 'custodial',
      encryptedPrivateKey,
      walletAddress: wallet.address,
      kycStatus: 'pending',
    });

    await this.userRepository.save(user);
    return { message: 'Signup successful', walletAddress: wallet.address };
  }

  async login(email: string, password: string) {
    console.log('Login attempt with:', email, password);

    const user = await this.userRepository.findOne({ where: { email } });
    console.log('Found user:', user);

    if (!user) throw new Error('Invalid credentials');

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) throw new Error('Invalid credentials');

    const token = this.jwtService.sign(
      { id: user.id, email: user.email, isAdmin: user.isAdmin },
      {
        secret: process.env.JWT_SECRET,
        expiresIn: '7d',
      },
    );

    return {
      token,
      user: {
        id: user.id,
        email: user.email,
        walletAddress: user.walletAddress,
        custodyMode: user.custodyMode,
        kycStatus: user.kycStatus,
      },
    };
  }

  async linkWallet(email: string, walletAddress: string) {
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user) throw new Error('User not found');

    user.walletAddress = walletAddress;
    user.custodyMode = 'self';
    user.encryptedPrivateKey = null;

    await this.userRepository.save(user);
    return { message: 'Wallet linked successfully' };
  }
  async findById(id: string) {
    return this.userRepository.findOne({ where: { id } });
  }
}
