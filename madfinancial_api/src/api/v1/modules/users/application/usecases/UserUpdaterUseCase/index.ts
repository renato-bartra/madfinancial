import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { User } from "../../../domain/entities/User";
import { UserRepository } from "../../../domain/repositories/UserRepository";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";

export class UserUpdaterUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly validatorManager: ValidatorManager
  ) {
  }

  update = async (id: number, user: User): Promise<User> => {
    // Primero Valida los datos
    await this.validatorManager.validate(user);
    if (this.validatorManager.error())
      throw new DataValidationException(this.validatorManager.getErrors());
    const data: User|null|string = await this.userRepository.update(id, user);
    if ( data === null ) throw new EntityNotFoundException();
    if ( typeof data === 'string' ) throw new DataBaseException(data); 
    return data;
  };
}
