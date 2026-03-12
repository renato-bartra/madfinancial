import { IErrorObject } from "./IErrorObject";

export interface ValidatorManager {
  validate: (entity: object) => Promise<object | null>;
  error: () => boolean|undefined;
  getErrors: () => IErrorObject[];
}