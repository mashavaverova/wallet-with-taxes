import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MarketplaceService } from './marketplace.service';
import { MarketplaceController } from './marketplace.controller';
import { Listing } from './entities/listing.entity';
import { Trade } from './entities/trade.entity';
import { TaxModule } from '../tax/tax.module';

@Module({
  imports: [TypeOrmModule.forFeature([Listing, Trade]), TaxModule],
  controllers: [MarketplaceController],
  providers: [MarketplaceService],
})
export class MarketplaceModule {}
