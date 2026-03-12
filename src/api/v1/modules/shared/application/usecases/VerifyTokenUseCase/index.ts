import { TokenException } from "../../../domain/exeptions/TokenException";
import { TokenManager } from "../../../domain/repositories/TokenManager";

export class VerifyTokenUseCase {
  constructor(private readonly tokenManager: TokenManager) {}

  public verify = async (token: string, roles: string[]): Promise<boolean> => {
    const tokenVerify = this.tokenManager.verify(token);
    if (this.tokenManager.error()){
      throw new TokenException(this.tokenManager.getError());
    }
    // verify roles
    if (!roles.some(role => tokenVerify.tou.includes(role))) 
      return false;
    return true;
  };
}
