export class EntityNotFoundException extends Error {
  constructor(){
    super ('Error: Los sentimos, el registro que estas buscando no existe en la base de datos')
  }
}