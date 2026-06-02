import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { User } from "../../../domain/entities/User";
import { UserRepository } from "../../../domain/repositories/UserRepository";

export class GetByIdUseCase {
  constructor( private readonly userRepository: UserRepository){}

  // consigue un usuario
  get = async(id: number): Promise<User> => {
    const data: User|null|string = await this.userRepository.getById(id);
    if (data === null) throw new EntityNotFoundException();
    if ( typeof data === 'string') throw new DataBaseException(data)
    return data;
  }
}