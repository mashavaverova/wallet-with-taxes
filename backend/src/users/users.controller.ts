import { Controller, Post, Body, Get, Req, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Request } from 'express';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('signup')
  async signup(@Body() body: { email: string; password: string }) {
    const { email, password } = body;
    return this.usersService.signup(email, password);
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    return this.usersService.login(body.email, body.password);
  }

  @Post('link-wallet')
  async linkWallet(@Body() body: { email: string; walletAddress: string }) {
    return this.usersService.linkWallet(body.email, body.walletAddress);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@Req() req: Request) {
    const user = req.user as { id: string; email: string }; // Add type assertion here
    return { user };
  }
}
