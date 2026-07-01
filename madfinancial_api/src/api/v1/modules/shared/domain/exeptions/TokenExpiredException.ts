export class TokenExpiredException extends Error {
  constructor(
    error: string = "El token a expirado. Continue con el refrescamiento del token"
  ) {
    super(error);
  }
}
