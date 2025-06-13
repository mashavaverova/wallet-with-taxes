import { useEffect, useState } from 'react';
import { getListings } from '../../lib/marketplaceview';
import '../../style/MarketplaceView.css';

type Listing = {
  id: number;
  tokenAddress: string;
  tokenId: number;
  amount: number;
  pricePerUnit: number;
  sellerId: string;
  status: string;
};

export default function MarketplaceView() {
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getListings()
      .then(res => {
        setListings(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error loading marketplace:', err);
        setLoading(false);
      });
  }, []);

  if (loading) return <p className="marketplace-loading">Loading marketplace...</p>;
  if (listings.length === 0) return <p className="marketplace-loading">No listings available.</p>;

  return (
    <div className="marketplace-container">
      <h2 className="marketplace-title">Marketplace Listings</h2>
      <table className="marketplace-table">
        <thead>
          <tr>
            <th>Token Address</th>
            <th>Token ID</th>
            <th>Amount</th>
            <th>Price</th>
            <th>Seller</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {listings.map(listing => (
            <tr key={listing.id}>
              <td>{listing.tokenAddress}</td>
              <td>{listing.tokenId}</td>
              <td>{listing.amount}</td>
              <td>${listing.pricePerUnit}</td>
              <td>{listing.sellerId}</td>
              <td>{listing.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
