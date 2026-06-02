import { User } from "../../../domain/entities/User";
import { UserRepository } from "../../../domain/repositories/UserRepository";

export class InMemoryUserRepository implements UserRepository {
  // esta es la capa de implementación solo tiene datos in memory
  public userData: User[] = [{
      user_id: 1,
      first_name: 'Renato',
      last_name: 'Bartra Reátegui@',
      dni: '71721506',
      email: 'rbr1593@gmail.com',
      password: '71721506',
      image: null,
      active: true
    },
    {
      user_id: 2,
      first_name: 'Jony',
      last_name: 'Bravo',
      dni: '71721508',
      email: 'jony@bravo.com',
      password: '71721506',
      image: null,
      active: true
    }
  ];
  // Consigue todos los usuarios
  getAll = async (): Promise<User[]> => {
    return this.userData;
  };
  // Crea un usario
  create = async (user: User): Promise<User|string> => {
    this.userData.push(user)
    return user;
  };
  // consigue un usuario por email
  getByEmail = async (email: string): Promise<User|null|string> => {
    const userFound: User|undefined = this.userData.find(x => x.email === email);
    if (userFound === undefined) return null; 
    return userFound;
  };
  // Consigue un usuario por id
  getById = async (id: number): Promise<User | null| string> => {
    const userFound: User|undefined = this.userData.find(x => x.user_id === id);
    if (userFound === undefined) return null;
    return userFound;
  };
  // Actualiza un usuario
  update = async (id: number, user: User): Promise<User|null|string> => {
    let userUpdate: User|undefined = this.userData.find(x => x.user_id === id);
    if (userUpdate === undefined) return null;
    userUpdate = user;
    return userUpdate;
  };
  // Anula un usuario
  delete = async (id: number): Promise<boolean> => {
    const userDeleted = this.userData.find(x => x.user_id !== id)!;
    if (userDeleted === undefined) return false;
    this.userData = [];
    this.userData.push(userDeleted)
    return true;
  };
  // Login de usuario
  login = async (email: string, password: string): Promise<boolean> => {
    return false;
  };
}
