import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { EmailValidatorManager } from "../../../../shared/domain/repositories/EmailValidatorManager";
import { User } from "../../../domain/entities/User";
import { UserRepository } from "../../../domain/repositories/UserRepository";

export class GetByEmailUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly emailvalidatorManager: EmailValidatorManager
  ) {}

  get = async (email: string): Promise<User> => {
    // Valida si el email enviado tiene el formato email
    await this.emailvalidatorManager.validate(email);
    if (this.emailvalidatorManager.error())
      throw new DataValidationException(this.emailvalidatorManager.getErrors());
    // Busca el usuario
    const user: User | null| string = await this.userRepository.getByEmail(email);
    if (user === null) throw new EntityNotFoundException();
    if (typeof user === 'string') throw new DataBaseException(user);
    return user;
  };
}
