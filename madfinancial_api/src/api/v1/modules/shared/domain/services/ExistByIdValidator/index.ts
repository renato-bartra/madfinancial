import { DataBaseException } from "../../exeptions/DataBaseException";
import { DomainRepository } from "../../repositories/DomainRepository";

export class ExistByIdValidator {
  constructor(private readonly domainRepository: DomainRepository) {}

  get = async (id: number): Promise<boolean> => {
    const entity = await this.domainRepository.getById(id);
    if (entity !== null) return true;
    if ( typeof entity === 'string') throw new DataBaseException(entity);
    return false;
  };
}