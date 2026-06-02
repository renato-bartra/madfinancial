import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { UserRepository } from "../../repositories/UserRepository";

export class ExistUserValidator {
  constructor(private readonly userRepository: UserRepository) {}

  get = async (email: string): Promise<boolean> => {
    const user = await this.userRepository.getByEmail(email);
    if (user === null) return false;
    if (typeof user === 'string') throw new DataBaseException(user)
    return true;
  };
}
