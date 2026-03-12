import { VerifyTokenUseCase } from "../usecases/VerifyTokenUseCase";
import { TokenException } from "../../domain/exeptions/TokenException";
import { IResponseObject } from "../../domain/repositories/IResponseObject";
import { TokenManager } from "../../domain/repositories/TokenManager";
import { JWTManager } from "../../infraestructure/implementations/JWT/JWTManager";

export class VerifyTokenController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private readonly tokenManager: TokenManager = new JWTManager();
  
  public verify = async(token: string, roles: string[]): Promise<boolean|IResponseObject> => {
    const verifyTokenUseCase = new VerifyTokenUseCase(this.tokenManager);
    try {
      const tokenVerify: boolean = await verifyTokenUseCase.verify(token, roles);
      if (!tokenVerify) {
        return this.data = {
          code: 401,
          message: 'Usted no tiene los permisos requeridos para ver esta información',
          body: []
        }
      }
      return tokenVerify;
    } catch (error) {
      if (error instanceof TokenException) {
        this.data = {
          code: 403,
          message: error.message,
          body: []
        }
      } else {
        this.data = {
          code: 500,
          message: "Lo sentimos, hubo un error en el servidor",
          body: []
        }
      }
      return this.data;
    }
  }
}