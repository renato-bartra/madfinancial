export class PasswordNotMatchException extends Error {
  constructor(){
    super ('Error: La nueva contraseña y la verificación de la contraseña no coinciden, por favor vuelva a intentarlo')
  }
}