import { User, UserID } from "../../../domain/entities/User";
import { UserRepository } from "../../../domain/repositories/UserRepository";
import { DBConfig } from "../../../../../config/DBConfig";
import postgres from "postgres";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";

export class PostgreSQLUserRepository implements UserRepository {
  private readonly dbConfig: DBConfig = new DBConfig();
  private readonly postgresConn = postgres({
    host: this.dbConfig.postgreSQLConn.host,
    port: this.dbConfig.postgreSQLConn.port,
    database: this.dbConfig.postgreSQLConn.database,
    username: this.dbConfig.postgreSQLConn.user,
    password: this.dbConfig.postgreSQLConn.password,
  });
  /* -------------------------------------------------------------------------- */
  /*                    Cnsigue todos los usuarios de la base                   */
  /* -------------------------------------------------------------------------- */
  getAll = async (): Promise<string | User[]> => {
    try{
      const response: User[] = await this.postgresConn<User[]>`SELECT * FROM users.sp_users_get_all()`;
      if (!response.length)
        throw new EntityNotFoundException()
      return response;
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };
  /* -------------------------------------------------------------------------- */
  /*                         Crea un usuario en la base                         */
  /* -------------------------------------------------------------------------- */
  create = async (user: User): Promise<string | User> => {
    try{
      const response = await this.postgresConn<User[]>`SELECT * FROM users.sp_users_save(
        ${user.first_name},
        ${user.last_name},
        ${user.dni},
        ${user.email},
        ${user.password},
        ${user.image}
      )`;
      return response[0]
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                       Consigue un usuarios por email                       */
  /* -------------------------------------------------------------------------- */
  getByEmail = async (email: string): Promise<string | User | null> => {
    try{
      const response: User[] = await this.postgresConn<User[]>`SELECT * FROM users.sp_users_get_by_email(${email})`;
      if (!response.length)
        return null
      return response[0];
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };
  /* -------------------------------------------------------------------------- */
  /*                         consigue un usuario por id                         */
  /* -------------------------------------------------------------------------- */
  getById = async (id: number): Promise<string | User | null> => {
    try{
      const response: User[] = await this.postgresConn<User[]>`SELECT * FROM users.sp_users_get_by_id(${id})`;
      if (!response.length)
        return null
      return response[0];
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };
  /* -------------------------------------------------------------------------- */
  /*                            Actualiza un usuario                            */
  /* -------------------------------------------------------------------------- */
  update = async (id: number, user: User): Promise<string | User | null> => {
    try{
      const response: UserID[] = await this.postgresConn<UserID[]>`SELECT * FROM users.sp_users_update(
        ${id},
        ${user.first_name},
        ${user.last_name},
        ${user.dni},
        ${user.image}
      )`;
      if (response[0].user_id != id)
        throw new EntityNotFoundException()
      if (!response.length)
        return null
      user.user_id = id
      return user;
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };
  /* -------------------------------------------------------------------------- */
  /*                              Anula un usuario                              */
  /* -------------------------------------------------------------------------- */
  delete = async (id: number): Promise<string | boolean> => {
    try{
      const response: UserID[] = await this.postgresConn<UserID[]>`SELECT * FROM users.sp_users_delete(${id})`;
      if (!response.length)
        return false
      if (response[0].user_id != id)
        throw new EntityNotFoundException()
      return true;
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };
}