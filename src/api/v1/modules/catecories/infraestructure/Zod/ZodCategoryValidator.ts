import { z, ZodError } from "zod";
import { IErrorObject } from "../../../shared/domain/repositories/IErrorObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { ZodErrorValidator } from "../../../shared/infraestructure/adapters/Zod/ZodErrorValidator";
import { UserCategory } from "../../domain/entities/Category";

export class ZodCategoryValidator implements ValidatorManager {
  private errors: IErrorObject[] = [];
  constructor(private watcher?: boolean) {}

  validate = async (userCategory: object): Promise<object | null> => {
    // Inicializa las validaciones regex
    const regex_description: RegExp = new RegExp(/^[a-zA-Z áéíóúñäëïöüÁÉÍÓÚÑ\s]*$/, 'i');
    // inicializa el exquema de zod
    const userSchema: z.ZodSchema<UserCategory> = z.strictObject({
      user_id: z.number(),
      category_id: z.number(),
      category_type: z.boolean(),
      description: z.string().regex(regex_description, {error:"El nombre solo debe contener letras"}).max(100)
    });
    // valida
    try {
      userSchema.parse(userCategory)
      this.watcher = false;
      return userCategory;
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
