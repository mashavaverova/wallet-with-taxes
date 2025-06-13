import axios from 'axios';

export const api = axios.create({
  baseURL: 'http://localhost:3000',
});

// Optionally!  attached token automatically
export const setAuthToken = (token: string | null) => {
  if (token) {
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common['Authorization'];
  }
};

