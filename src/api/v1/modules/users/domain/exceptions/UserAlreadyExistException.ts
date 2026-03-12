export class UserAlreadyExistException extends Error {
  constructor(){
    super('Error: El email ya se encuentra registrado, por favor intentar con otro email')
  }
}