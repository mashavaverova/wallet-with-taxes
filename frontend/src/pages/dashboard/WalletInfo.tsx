import { useEffect, useState } from 'react';
import { getWalletBalance, getWalletAssets } from '../../lib/wallets';
import { getMe } from '../../lib/users';

export default function WalletInfo() {
  const [walletAddress, setWalletAddress] = useState<string | null>(null);
  const [balance, setBalance] = useState<string | null>(null);
  const [assets, setAssets] = useState<{ name: string; symbol: string; balance: number }[]>([]);

  useEffect(() => {
    getMe()
      .then(res => {
        const address = res.data.walletAddress;
        setWalletAddress(address);
        return Promise.all([
          getWalletBalance(address),
          getWalletAssets(address),
        ]);
      })
      .then(([balanceRes, assetsRes]) => {
        setBalance(balanceRes.data.balance);
        setAssets(assetsRes.data.assets);
      })
      .catch(err => {
        console.error('Failed to load wallet info:', err);
      });
  }, []);

  if (!walletAddress || !balance) return <p>Loading wallet...</p>;

  return (
    <div className="border rounded-lg p-4 shadow">
      <h2 className="text-lg font-semibold mb-2">Wallet Info</h2>
      <p><strong>Address:</strong> {walletAddress}</p>
      <p><strong>Balance:</strong> {balance}</p>

      <h3 className="mt-4 font-semibold">Assets</h3>
      {assets.length === 0 ? (
        <p>No assets</p>
      ) : (
        <ul className="list-disc list-inside">
          {assets.map((asset, i) => (
            <li key={i}>
              {asset.name} ({asset.symbol}): {asset.balance}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
