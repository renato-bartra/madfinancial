import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { SharedRepository } from "../../repositories/SharedRepository";

export class ExistEmailValidator {
  constructor(private readonly sharedRepo: SharedRepository) {}

  get = async (email: string): Promise<boolean> => {
    const user = await this.sharedRepo.getByEmail(email);
    if (this.sharedRepo.error())
      throw new DataBaseException(this.sharedRepo.getError())
    if (user === null) return false;
    return true;
  };
}