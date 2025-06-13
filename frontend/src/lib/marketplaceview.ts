import { api } from './api';

export const getListings = () =>
  api.get('/marketplace/listings'); 
