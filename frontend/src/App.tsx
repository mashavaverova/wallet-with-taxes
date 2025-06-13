// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { useEffect } from 'react';
import { setAuthToken } from './lib/api';
import Login from './pages/Login';
import Dashboard from './pages/dashboard/index_dash';
import './index.css';


function App() {

  
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) setAuthToken(token);
  }, []);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
