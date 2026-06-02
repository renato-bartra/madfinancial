import { User } from "../../../../users/domain/entities/User";
import { DataBaseException } from "../../../domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../domain/exeptions/EntityNotFoundException";
import { SMTPException } from "../../../domain/exeptions/SMTPException";
import { TokenException } from "../../../domain/exeptions/TokenException";
import { ITokenObject } from "../../../domain/repositories/ITokenObject";
import { SharedRepository } from "../../../domain/repositories/SharedRepository";
import { SMTPManager } from "../../../domain/repositories/SMTPManager";
import { TokenManager } from "../../../domain/repositories/TokenManager";

export class ForgotPasswordUseCase {
  constructor(
    private readonly sharedRepo: SharedRepository,
    private readonly tokenManager: TokenManager,
    private readonly smtpManager: SMTPManager
  ) {}

  make = async (email: string): Promise<boolean> => {
    // Busca el usuario
    const user: User | null = await this.sharedRepo.getByEmail(
      email
    );
    if (this.sharedRepo.error())
      throw new DataBaseException(this.sharedRepo.getError())
    if (user === null) throw new EntityNotFoundException();
    // Crea el token
    const tokenObject: ITokenObject = {
      sub: user.user_id,
      son: user.first_name,
      ema: user.email,
      tou: ['user', 'londge'],
    };
    const token: string = await this.tokenManager.makeForResetPass(tokenObject);
    // valida si el token se creó
    if (this.tokenManager.error())
      throw new TokenException(this.tokenManager.getError());
    // Crea el tranportador smtp
    const transporter = await this.smtpManager.createTransporter();
    if (this.smtpManager.error())
      throw new SMTPException(this.smtpManager.getErrors());
    // Envia el email
    this.smtpManager.setResetPassMailTemplate(user.first_name, token);
    await this.smtpManager.sendEmail(
      transporter,
      user.email,
      user.first_name,
      "Restablece tu contraseña"
    );
    if (this.smtpManager.error())
      throw new SMTPException(this.smtpManager.getErrors())
    return true;
  }
}