import { IErrorObject } from "./IErrorObject";

export interface EmailValidatorManager {
  validate: (email: string) => Promise<string | null>;
  error: () => boolean|undefined;
  getErrors: () => IErrorObject[];
}