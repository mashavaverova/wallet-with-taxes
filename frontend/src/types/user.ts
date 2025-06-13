export interface User {
    id: string;
    email: string;
    walletAddress: string;
    custodyMode: 'custodial' | 'self';
    kycStatus: 'pending' | 'verified' | 'rejected';
    isAdmin: boolean;
    onChainWallet?: string;
    createdAt: string;
  }
  