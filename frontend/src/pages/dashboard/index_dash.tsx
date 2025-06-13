import { useEffect, useState } from 'react';
import { getMe } from '../../lib/users';
import UserInfo from './UserInfo';
import WalletInfo from './WalletInfo';
import MarketplaceView from './MarketplaceView';
import type { User } from '../../types/User';
import '../../style/Dashboard.css';

export default function Dashboard() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    getMe()
      .then(res => setUser(res.data)) 
      .catch(() => {
        window.location.href = '/';
      });
  }, []);

  if (!user) return <p className="loading-text">Loading...</p>;

  return (
    <div className="dashboard-container">
      <h1 className="dashboard-title">User Dashboard</h1>
      <UserInfo user={user} />
      <WalletInfo />
      <MarketplaceView />
    </div>
  );
}
