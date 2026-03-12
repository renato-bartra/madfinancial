import { TokenManager } from "../../../../shared/domain/repositories/TokenManager";
import { PasswordManager } from "../../../../shared/domain/repositories/PasswordManager";
import { UserRepository } from "../../../domain/repositories/UserRepository";
import { User } from "../../../domain/entities/User";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { ITokenObject } from "../../../../shared/domain/repositories/ITokenObject";
import { TokenException } from "../../../../shared/domain/exeptions/TokenException";

export class UserLoginUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly passwordManager: PasswordManager,
    private readonly tokenManager: TokenManager
  ) {}

  login = async (email: string, password: string): Promise<[string, User]> => {
    // Traer el usuario del DB
    const user: User | string | null = await this.userRepository.getByEmail(email);
    if (typeof user === "string") throw new DataBaseException(user);
    if (user === null) throw new EntityNotFoundException();
    // Decrypt password
    const passDecrypt: boolean = await this.passwordManager.decrypt(
      password,
      user.password
    );
    if (!passDecrypt) throw new EntityNotFoundException();
    // Crea el token, primero el objeto que va a hashear
    const userName: string = user.first_name + " " + user.last_name;
    const tokenObject: ITokenObject = {
      sub: user.user_id,
      son: userName,
      ema: user.email,
      tou: ['user']
    };
    const token: string = await this.tokenManager.make(tokenObject);
    // valida si el token se creó
    if (this.tokenManager.error())
      throw new TokenException(this.tokenManager.getError());
    return [token, user];
  };
}
