import { IErrorObject } from "../repositories/IErrorObject"

export class DataValidationException extends Error {
  constructor(private readonly errors: IErrorObject[]){
    super ('Error: Los datos del enviados no tienen el formato requerido')
  }
  // Si necesita los errores le devuelve en forma de objeto
  getErrors = () => {
    return this.errors
  }
}