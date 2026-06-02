export class TokenException extends Error {
  constructor(
    error: string = "Lo sentimos pero usted no tiene los privilegios para realizar esta acción"
  ) {
    super(error);
  }
}
