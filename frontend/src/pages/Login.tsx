// src/pages/Login.tsx
import { useState } from 'react';
import { login } from '../lib/users';
import { setAuthToken } from '../lib/api';
import { useNavigate } from 'react-router-dom';
import '../style/Login.css';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleLogin = async () => {
    try {
      const { data } = await login(email, password);
      setAuthToken(data.token);
      localStorage.setItem('token', data.token);
      navigate('/dashboard');
    } catch (err) {
      alert('Login failed');
      console.error(err);
    }
  };

  return (
    <div className="login-page">
      <div className="login-box">
        <h1 className="login-title">Welcome to Genesis</h1>
        <div className="login-fields">
          <input
            type="email"
            placeholder="Email"
            className="login-input"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <input
            type="password"
            placeholder="Password"
            className="login-input"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button onClick={handleLogin} className="login-button">
            Sign In
          </button>
        </div>
        <p className="login-footer">
          Don’t have an account? <span className="signup-link">Sign up</span>
        </p>
      </div>
    </div>
  );
}
