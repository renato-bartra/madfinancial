import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { PasswordManager } from "../../../shared/domain/repositories/PasswordManager";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { User } from "../../domain/entities/User";
import { UserAlreadyExistException } from "../../domain/exceptions/UserAlreadyExistException";
import { UserRepository } from "../../domain/repositories/UserRepository";
import { ExistUserValidator } from "../../domain/services/ExistUserValidator";

export class UserCreatorUseCase {
  private readonly existUser: ExistUserValidator;
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordManager: PasswordManager,
    private readonly validatorManager: ValidatorManager
  ) {
    this.existUser = new ExistUserValidator(userRepository);
  }

  create = async (user: User): Promise<User> => {
    // primero valida los datos
    await this.validatorManager.validate(user);
    if (this.validatorManager.error()){
      throw new DataValidationException(this.validatorManager.getErrors());
    }
    // valida si el email ya se encuentra registrado en la base de datos
    const existUser: boolean = await this.existUser.get(user.email);
    if (existUser) throw new UserAlreadyExistException();
    // Si no existe entonces encripta la contraseña
    user.password = await this.passwordManager.encrypt(user.password);
    // crea el usuario
    const userCreator: User|string = await this.userRepository.create(user);
    if (typeof userCreator === 'string') throw new DataBaseException(userCreator);
    return userCreator;
  };
}
