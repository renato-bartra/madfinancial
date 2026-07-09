import { IErrorObject } from "../repositories/IErrorObject"

export class DataValidationException extends Error {
  constructor(private readonly errors: IErrorObject[]){
    super (`Error: Los datos enviados no tienen el formato requerido. ${
      errors
      .map(error => `${error.attribute}: ${error.message ?? 'Error desconocido'}`)
      .join('; ')
    }`)
  }
  // Si necesita los errores le devuelve en forma de objeto
  getErrors = () => {
    return this.errors
  }
}