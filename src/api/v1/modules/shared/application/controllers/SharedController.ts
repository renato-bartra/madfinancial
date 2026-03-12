import { EntityNotFoundException } from "../../domain/exeptions/EntityNotFoundException";
import { PasswordNotMatchException } from "../../domain/exeptions/PasswordNotMatchException";
import { SMTPException } from "../../domain/exeptions/SMTPException";
import { TokenException } from "../../domain/exeptions/TokenException";
import { IResponseObject } from "../../domain/repositories/IResponseObject";
import { PasswordManager } from "../../domain/repositories/PasswordManager";
import { SMTPManager } from "../../domain/repositories/SMTPManager";
import { JWTManager } from "../../infraestructure/implementations/JWT/JWTManager";
import { NodeMailerManager } from "../../infraestructure/implementations/NodeMailer/NodeMailerManager";
import { PasswordBcrypt } from "../../infraestructure/implementations/PasswordBcript";
import { PostgreSQLSharedRepositori } from "../../infraestructure/implementations/PostgreSQL/PostgreSQLSharedRepository";
import { ForgotPasswordUseCase } from "../usecases/ForgotPasswordUseCase";
import { ResetPasswordUseCase } from "../usecases/ResetPasswordUseCase";

export class SharedController {
  private readonly sharedRepository: PostgreSQLSharedRepositori = new PostgreSQLSharedRepositori();
  private readonly tokenManager: JWTManager = new JWTManager();
  private passwordManager: PasswordManager = new PasswordBcrypt(11);
  private smtpManager: SMTPManager = new NodeMailerManager();
  private data: IResponseObject = { code: 0, message: "", body: [] };

  /* -------------------------------------------------------------------------- */
  /*                             Resetea la Password                            */
  /* -------------------------------------------------------------------------- */
  resetPassword = async(token: string, password: string, confirm: string): Promise<IResponseObject> =>{
    const resetPasswordUseCase: ResetPasswordUseCase = new ResetPasswordUseCase(
      this.sharedRepository,
      this.tokenManager,
      this.passwordManager
    )
    try {
      await resetPasswordUseCase.reset(token, password, confirm)
      this.data = {
        code: 200,
        message: 'La contraseña se cambió exitosamente',
        body: []
      }
    } catch (error) {
      if(error instanceof EntityNotFoundException){
        this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else if (error instanceof TokenException){
        this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else if(error instanceof PasswordNotMatchException){
        this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: "Error: Lo sentimos, hubo un error en el servidor",
          body: [],
        };
      }
    }
    return this.data;
  }

  /* -------------------------------------------------------------------------- */
  /*                    Solicitud para restablecer contraseña                   */
  /* -------------------------------------------------------------------------- */
  forgotPass = async (email: string): Promise<IResponseObject> => {
    const forgotPasswordUseCase: ForgotPasswordUseCase =
      new ForgotPasswordUseCase(
        this.sharedRepository,
        this.tokenManager,
        this.smtpManager
      );
    try {
      const emailSend: boolean = await forgotPasswordUseCase.make(email);
      this.data = {
        code: 200,
        message: 'El email fue enviado con exito, por favor revise su bandeja de entrada',
        body: []
      }
    } catch (error) {
      if(error instanceof EntityNotFoundException) {
        this.data = {
          code: 404,
          message: "El correo que proporcionó no existe en nuestra base de datos, por favor ingresar el que le proporcionó DIRCETUR",
          body: [],
        };
      } else if (error instanceof TokenException){
        this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else if (error instanceof SMTPException){
        this.data = {
          code: 503,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
}