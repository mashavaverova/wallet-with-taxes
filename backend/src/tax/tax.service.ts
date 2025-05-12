import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TaxEvent } from './entities/tax-event.entity';

@Injectable()
export class TaxService {
  constructor(
    @InjectRepository(TaxEvent)
    private readonly repo: Repository<TaxEvent>,
  ) {}

  async logEvent(data: Partial<TaxEvent>) {
    const event = this.repo.create(data);
    return this.repo.save(event);
  }
}
