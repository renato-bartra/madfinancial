import { z, ZodError } from "zod";
import { IErrorObject } from "../../../shared/domain/repositories/IErrorObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { ZodErrorValidator } from "../../../shared/infraestructure/adapters/Zod/ZodErrorValidator";
import { UserTag } from "../../domain/entities/Tag";

export class ZodTagValidator implements ValidatorManager {
  private errors: IErrorObject[] = [];
  constructor(private watcher?: boolean) {}

  validate = async (userTag: object): Promise<object | null> => {
    // Inicializa las validaciones regex
    const regex_description: RegExp = new RegExp(/^[a-zA-Z áéíóúñäëïöüÁÉÍÓÚÑ\s]*$/, 'i');
    // inicializa el exquema de zod
    const userSchema: z.ZodSchema<UserTag> = z.strictObject({
      user_id: z.number(),
      tag_id: z.number(),
      description: z.string().regex(regex_description, {error:"El nombre solo debe contener letras"}).max(100)
    });
    // valida
    try {
      userSchema.parse(userTag)
      this.watcher = false;
      return userTag;
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
    return this.watcher;
  };
  
  getErrors = (): IErrorObject[] => {
    return this.errors;
  };
}
