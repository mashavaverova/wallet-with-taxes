import { api } from './api';
import type { User } from '../types/User';

export const signup = (email: string, password: string) =>
  api.post('/users/signup', { email, password });

export const login = (email: string, password: string) =>
  api.post('/users/login', { email, password });

export const linkWallet = (email: string, walletAddress: string) =>
  api.post('/users/link-wallet', { email, walletAddress });

export const getMe = () => api.get<User>('/users/me');
