import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { UserRepository } from "../../../domain/repositories/UserRepository";

export class UserDeleterUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  delete = async (id: number): Promise<boolean> => {
    const deleter = await this.userRepository.delete(id);
    if ( typeof deleter === 'string') throw new DataBaseException(deleter)
    if (deleter === false) throw new EntityNotFoundException();
    return deleter;
  }
}
