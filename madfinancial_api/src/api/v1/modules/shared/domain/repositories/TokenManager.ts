import { ITokenObject } from "./ITokenObject";

export interface TokenManager {
  make: (params:ITokenObject) => Promise<string>;
  verify: (token: string) => ITokenObject;
  makeForResetPass: (params:ITokenObject) => Promise<string>;
  verifyForResetPass: (token: string) => ITokenObject;
  error: () => boolean;
  getError: () => string;
}