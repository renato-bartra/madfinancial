export class DataBaseException extends Error {
  constructor(message: string){
    super (`DBException ${message}`)
  }
}