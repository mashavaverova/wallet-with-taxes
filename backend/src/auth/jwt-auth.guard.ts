import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    console.log('JwtAuthGuard is active');
    return super.canActivate(context);
  }

  handleRequest<TUser = any>(err: unknown, user: TUser, info: unknown): TUser {
    console.log('AuthGuard user:', user);
    console.log('AuthGuard error:', err);
    console.log('AuthGuard info:', info);

    if (err || !user) {
      throw new UnauthorizedException();
    }
    return user;
  }
}
