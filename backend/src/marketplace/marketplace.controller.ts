import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { Request } from 'express';
import { MarketplaceService } from './marketplace.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

import { ListItemDto } from './dto/list-item.dto';
import { TradeDto } from './dto/trade.dto';
import { JwtUser } from '../auth/jwt-user.interface';
import { GetListingsQueryDto } from './dto/get-listings-query.dto';

@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  @UseGuards(JwtAuthGuard)
  @Post('list')
  listItem(@Body() dto: ListItemDto, @Req() req: Request & { user: JwtUser }) {
    return this.marketplaceService.listItem(dto, req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Post('trade')
  executeTrade(@Body() dto: TradeDto, @Req() req: Request & { user: JwtUser }) {
    return this.marketplaceService.executeTrade(dto, req.user);
  }

  @Get('listings')
  getListings(@Query() query: GetListingsQueryDto) {
    return this.marketplaceService.getListings(query);
  }
}
