import { api } from './api';

export const getWalletBalance = (address: string) =>
  api.get('/wallets/balance', { params: { address } });

export const getWalletAssets = (address: string) =>
  api.get('/wallets/assets', { params: { address } });

export const getAssetDetail = (address: string, id: string) =>
  api.get(`/wallets/assets/${id}`, { params: { address } });
