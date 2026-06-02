import { z, ZodError } from "zod";
import { EmailValidatorManager } from "../../../domain/repositories/EmailValidatorManager";
import { IErrorObject } from "../../../domain/repositories/IErrorObject";
import { ZodErrorValidator } from "../../adapters/Zod/ZodErrorValidator";

export class EmailValidator implements EmailValidatorManager {
  private watcher: boolean = false;
  private errors: IErrorObject[] = [];
  
  validate = async (vemail: string): Promise<string | null> => {
    const emailSchema = z.strictObject({
      email: z.email({
        message:
          "Por favor, el email debe tener el formato correcto, ejmp: ejemplo@ejemplo.com",
      })
    })
    try {
      emailSchema.parse({email: vemail});
      return vemail;
    } catch (error) {
      this.watcher = true;
      if (error instanceof ZodError) {
        let zodErrorValidator = new ZodErrorValidator(error);
        this.errors = await zodErrorValidator.getErrorMessage()
      }
      return null;
    }
  };

  error = (): boolean | undefined => {
    return this.watcher
  };

  getErrors = (): IErrorObject[] => {
    return this.errors
  };
}
