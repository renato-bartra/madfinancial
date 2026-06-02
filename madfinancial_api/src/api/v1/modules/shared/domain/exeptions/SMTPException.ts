export class SMTPException extends Error {
  constructor(message: string){
    super (`Error: ${message}`)
  }
}