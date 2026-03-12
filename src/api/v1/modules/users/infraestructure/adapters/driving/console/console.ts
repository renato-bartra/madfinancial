import { IResponseObject } from "src/api/v1/modules/shared/domain/repositories/IResponseObject";
import { UserController } from "../../../../application/controllers";
import { User } from "../../../../domain/entities/User";
import { InMemoryUserRepository } from "../../../implementations/inMemory/InMemoryUserrepository";

const consoleCreate = async () => { 
  // const userData = new InMemoryUserRepository()
  // console.log(userData.userData);
  const userCreatorUseCase = new UserController()
  const user: User = {
    user_id: 3,
    first_name: 'Prueba',
    last_name: 'Prueba Prueba',
    dni: '71721506',
    email: 'prueba@prueba.com',
    password: 'renato',
    image: null,
    active: null
  };
  const data: IResponseObject = await userCreatorUseCase.delete(413338624);
  // console.log('Esto el log en console adapter ', data);
  console.log(data);
}
consoleCreate();
