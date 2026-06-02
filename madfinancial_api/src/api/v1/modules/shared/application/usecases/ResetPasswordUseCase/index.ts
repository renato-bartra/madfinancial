import { DataBaseException } from "../../../domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../domain/exeptions/EntityNotFoundException";
import { PasswordNotMatchException } from "../../../domain/exeptions/PasswordNotMatchException";
import { TokenException } from "../../../domain/exeptions/TokenException";
import { ITokenObject } from "../../../domain/repositories/ITokenObject";
import { PasswordManager } from "../../../domain/repositories/PasswordManager";
import { SharedRepository } from "../../../domain/repositories/SharedRepository";
import { TokenManager } from "../../../domain/repositories/TokenManager";

export class ResetPasswordUseCase {
  constructor(
    private readonly sharedRepository: SharedRepository,
    private readonly tokenManager: TokenManager,
    private readonly passwordManager: PasswordManager
  ) {}

  reset = async (token: string, password: string, confirm: string): Promise<boolean> => {
    // verifica el token
    const verifyToken: ITokenObject = this.tokenManager.verifyForResetPass(token);
    if (this.tokenManager.error())
      throw new TokenException(this.tokenManager.getError());
    // Valida las contraseñas
    if (password !== confirm) throw new PasswordNotMatchException();
    // encripta
    const passwordEncript: string = await this.passwordManager.encrypt(
      password
    );
    // Persiste en la base de datos
    const passChanged: boolean = await this.sharedRepository.changePassword(
      verifyToken.sub,
      passwordEncript
    );
    if (this.sharedRepository.error())
      throw new DataBaseException(this.sharedRepository.getError())
    if(!passChanged) throw new EntityNotFoundException();
    return true;
  };
}
