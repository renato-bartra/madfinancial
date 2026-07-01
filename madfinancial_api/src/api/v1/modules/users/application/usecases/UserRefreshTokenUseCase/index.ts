import { TokenManager } from "../../../../shared/domain/repositories/TokenManager";
import { UserRepository } from "../../../domain/repositories/UserRepository";
import { User } from "../../../domain/entities/User";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { ITokenObject } from "../../../../shared/domain/repositories/ITokenObject";
import { TokenException } from "../../../../shared/domain/exeptions/TokenException";

export class UserRefreshTokenUseCase {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly tokenManager: TokenManager
  ) {}

  refresh = async (email: string, token: string): Promise<string> => {
    // Consigue el unsuario
    const user: User | string | null = await this.userRepository.getByEmail(email);
    if (typeof user === "string") throw new DataBaseException(user);
    if (user === null) throw new EntityNotFoundException();
    // Valida que el token se encuentre expirado
    this.tokenManager.verify(token)
    if (this.tokenManager.getError() != "El token a expirado") {
      throw new TokenException()
    }
    // Crea el token, primero el objeto que va a hashear
    const userName: string = user.first_name + " " + user.last_name;
    const tokenObject: ITokenObject = {
      sub: user.user_id,
      son: userName,
      ema: user.email,
      tou: ['user']
    };
    const newToken: string = await this.tokenManager.make(tokenObject);
    // valida si el token se creó
    if (this.tokenManager.error())
      throw new TokenException(this.tokenManager.getError());
    return newToken;
  };
}
