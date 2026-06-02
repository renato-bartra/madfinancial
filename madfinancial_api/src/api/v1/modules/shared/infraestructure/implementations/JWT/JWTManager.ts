import jwt, { JsonWebTokenError, TokenExpiredError } from "jsonwebtoken";
import { ITokenObject } from "../../../domain/repositories/ITokenObject";
import { TokenManager } from "../../../domain/repositories/TokenManager";
import { KeysConfig } from "../../../../../config/KeysConfig";

export class JWTManager implements TokenManager {
  private jwtValidator: boolean;
  private jwtError: string;
  private readonly keysConfig: KeysConfig;
  private readonly jwtSecret: string;
  private readonly jwtMailSecret: string;
  constructor () {
    this.jwtValidator = false;
    this.jwtError = '';
    this.keysConfig = new KeysConfig();
    this.jwtSecret = this.keysConfig.keys.jwtSecret;
    this.jwtMailSecret = this.keysConfig.keys.jwtMailSecret;
  }
  /* -------------------------------------------------------------------------- */
  /*                            Generate login token                            */
  /* -------------------------------------------------------------------------- */
  make = async (params: ITokenObject): Promise<string> => {
    let token: string = "";
    try {
      token = jwt.sign(params, this.jwtSecret, { expiresIn: "3h" });
    } catch (error) {
      token = "";
      this.jwtValidator = true;
      this.jwtError =
        "Lo sentimos, hubo un error al generar el token, por favor intentelo nuevamente";
    }
    return token;
  };
  /* -------------------------------------------------------------------------- */
  /*                             Verify login token                             */
  /* -------------------------------------------------------------------------- */
  verify = (token: string): ITokenObject => {
    let verifyToken: ITokenObject = { sub: 1, son: "", ema: "", tou: [] };
    try {
      verifyToken = jwt.verify(token, this.jwtSecret) as any;
      if(verifyToken.sub) {
        this.jwtValidator = false;
        return verifyToken;
      }
    } catch (error) {
      this.jwtValidator = true;
      if (error instanceof TokenExpiredError){
        this.jwtError =
          `El token a expirado, por favor vuelva a realizar un login`;
      }
      else if (error instanceof JsonWebTokenError)
        this.jwtError =
          "El token sufrió una malformación, por favor vuelva a realizar un login";
      else
        this.jwtError =
          "Lo sentimos, hubo un error al validar el token, por favor vuelva a realizar un login";
    }
    return verifyToken;
  };
  /* -------------------------------------------------------------------------- */
  /*                    Generate token for recovery password                    */
  /* -------------------------------------------------------------------------- */
  makeForResetPass = async (params: ITokenObject): Promise<string> => {
    let token: string = "";
    try {
      token = jwt.sign(params, this.jwtMailSecret, { expiresIn: 5*60 });
    } catch (error) {
      token = "";
      this.jwtValidator = true;
      this.jwtError =
        "Lo sentimos, hubo un error al generar el token, por favor intentelo nuevamente";
    }
    return token;
  };
  /* -------------------------------------------------------------------------- */
  /*                       Verify token for reset Password                      */
  /* -------------------------------------------------------------------------- */
  verifyForResetPass = (token: string): ITokenObject => {
    let verifyToken: ITokenObject = { sub: 1, son: "", ema: "", tou: [] };
    try {
      verifyToken = jwt.verify(token, this.jwtMailSecret) as any;
      if(verifyToken.sub) {
        this.jwtValidator = false;
        return verifyToken;
      }
    } catch (error) {
      this.jwtValidator = true;
      if (error instanceof TokenExpiredError)
        this.jwtError =
          "El token a expirado, por favor vuelva a intentarlo";
      else if (error instanceof JsonWebTokenError)
        this.jwtError =
          "El token sufrió una malformación, por favor vuelva a intentarlo";
      else
        this.jwtError =
          "Hubo un error al validar el token, por favor vuelva a intentarlo";
    }
    return verifyToken;
  };
  /* -------------------------------------------------------------------------- */
  /*                            Validador de errores                            */
  /* -------------------------------------------------------------------------- */
  error = (): boolean => this.jwtValidator;
  /* -------------------------------------------------------------------------- */
  /*                            Consigue los errores                            */
  /* -------------------------------------------------------------------------- */
  getError = (): string => this.jwtError;
}
