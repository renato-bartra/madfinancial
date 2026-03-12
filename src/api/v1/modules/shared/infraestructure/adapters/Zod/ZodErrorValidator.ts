import { z, ZodError } from "zod";
import { IErrorObject } from "../../../domain/repositories/IErrorObject";

export class ZodErrorValidator {
  constructor(private error: ZodError) {}

  getErrorMessage = async (): Promise<IErrorObject[]> => {
    let errorsObject: IErrorObject[] = [];
    const errors = z.flattenError(this.error);
    // Iterar por formErrors (sin atributo) En caso se envien más elementos de lo permitido en el formulario
    if (errors.formErrors.length > 0) {
      for (const err of errors.formErrors) {
        errorsObject.push({
          attribute: '',
          message: err,
        });
      }
    }
    // Iterar por fieldErrors en caso errores en el formulario enviado
    // si hay más de un error por atributo, se unen con coma
    for (const [key, msgs] of Object.entries(errors.fieldErrors)) {
      let errorMessage: string = Array.isArray(msgs) ? msgs.join(", ") : "";
      errorsObject.push({
        attribute: key.toString(),
        message: errorMessage,
      });
    }
    return errorsObject
  }
}