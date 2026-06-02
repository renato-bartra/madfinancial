import { z, ZodError } from "zod";
import { IErrorObject } from "../../../shared/domain/repositories/IErrorObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { ZodErrorValidator } from "../../../shared/infraestructure/adapters/Zod/ZodErrorValidator";

export class ZodMovementValidator implements ValidatorManager {
  private errors: IErrorObject[] = [];
  constructor(private watcher?: boolean) {}

  private readonly spanishWordsRegex = /^[a-záéíóúñäëïöü\s]+$/i;

  private readonly tagSchema = z.object({
    tag_id: z.number(),
    description: z.string().regex(this.spanishWordsRegex, {
      error: "La descripción del tag solo debe contener palabras en español",
    }),
  });

  private readonly categorySchema = z.object({
    category_id: z.number(),
    category_type: z.boolean(),
    description: z.string().regex(this.spanishWordsRegex, {
      error: "La descripción de la categoría solo debe contener palabras en español",
    }),
  });

  private readonly typeSchema = z.object({
    type_id: z.number(),
    description: z.string().regex(this.spanishWordsRegex, {
      error: "La descripción del tipo solo debe contener palabras en español",
    }),
  });

  private readonly accountSchema = z.object({
    account_id: z.number(),
    description: z.string().regex(this.spanishWordsRegex, {
      error: "La descripción de la cuenta solo debe contener palabras en español",
    }),
  });

  private readonly submovementSchema = z.object({
    submovement_id: z.number(),
    description: z.string().regex(this.spanishWordsRegex, {
      error: "La descripción del submovimiento solo debe contener palabras en español",
    }),
    amount: z.number(),
    subcategory: this.categorySchema,
    tags: z.array(this.tagSchema),
  });

  private readonly movementSchema = z.object({
    movement_id: z.number(),
    user_id: z.number(),
    title: z.string()
      .regex(this.spanishWordsRegex, {
        error: "El título solo debe contener palabras en español",
      })
      .max(150),
    description: z.string()
      .regex(this.spanishWordsRegex, {
        error: "La descripción solo debe contener palabras en español",
      })
      .max(500),
    amount: z.number(),
    accounting_date: z.iso.date(),
    type: this.typeSchema,
    category: this.categorySchema,
    account: this.accountSchema,
    tags: z.array(this.tagSchema),
    submovements: z.array(this.submovementSchema),
  });

  validate = async (movement: object): Promise<object | null> => {
    try {
      this.movementSchema.parse(movement);
      this.watcher = false;
      return movement;
    } catch (error) {
      this.watcher = true;
      if (error instanceof ZodError) {
        const zodErrorValidator = new ZodErrorValidator(error);
        this.errors = await zodErrorValidator.getErrorMessage();
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
