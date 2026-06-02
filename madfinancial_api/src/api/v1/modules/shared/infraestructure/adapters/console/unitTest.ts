import { z, ZodError } from "zod";
import { IErrorObject } from "../../../domain/repositories/IErrorObject";
import { ZodErrorValidator } from "../Zod/ZodErrorValidator";

const ZodUConsoleUnitTest = async() => {
  const email: object = {emai: "eretg@gmail", sdfsdf: "dfsdfsedf"};
  let errors: IErrorObject[] = [];
  const emailSchema = z.strictObject({
    email : z.email({
      message:
        "Por favor, el email debe tener el formato correcto, ejmp: ejemplo@ejemplo.com",
    })
  });
  try {
    emailSchema.parse(email);
    console.log("todo OK");
  } catch (error) {
    if (error instanceof ZodError) {
      let zodErrorValidator = new ZodErrorValidator(error);
      errors = await zodErrorValidator.getErrorMessage();
      console.log(errors)
    }
    console.log("Hubo un error");
  }
}

ZodUConsoleUnitTest()