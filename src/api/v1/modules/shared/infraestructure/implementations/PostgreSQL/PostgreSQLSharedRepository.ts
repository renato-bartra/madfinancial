import { DBConfig } from "../../../../../config/DBConfig";
import { SharedRepository } from "../../../domain/repositories/SharedRepository";
import { User, UserID } from "../../../../users/domain/entities/User";
import postgres from "postgres";
import { EntityNotFoundException } from "../../../domain/exeptions/EntityNotFoundException";

export class PostgreSQLSharedRepositori implements SharedRepository {
  private errorValidate: boolean = false;
  private errors: string = "";
  private readonly dbConfig: DBConfig = new DBConfig();
  private readonly postgresConn = postgres({
      host: this.dbConfig.postgreSQLConn.host,
      port: this.dbConfig.postgreSQLConn.port,
      database: this.dbConfig.postgreSQLConn.database,
      username: this.dbConfig.postgreSQLConn.user,
      password: this.dbConfig.postgreSQLConn.password,
    });

  changePassword = async (id: number, password: string): Promise<boolean> => {
    try{
      const response: UserID[] = await this.postgresConn<UserID[]>`SELECT * FROM users.sp_change_password_by_id(${id}, ${password})`;
      if (!response[0]){
        this.errorValidate = true;
        this.errors = "El usuario no se encuentra en nuestra base de datos"
        throw new EntityNotFoundException()
      }
      this.errorValidate = false;
      return true;
    }catch(err){
      this.errorValidate = true;
      if (err instanceof Error){
        this.errors = err.message
      }
      this.errors = "Hubo un error inesperado"
      return false
    }
  };

  getByEmail = async (email: string): Promise<User | null> => {
    try{
      const response: User[] = await this.postgresConn<User[]>`SELECT * FROM users.sp_users_get_by_email(${email})`;
      if (!response.length)
        throw new EntityNotFoundException()
      this.errorValidate = false;
      return response[0];
    }catch(err){
      if (err instanceof Error){
        this.errorValidate = true;
        this.errors = err.message;
        return null
      }
      this.errorValidate = true;
      this.errors = "Hubo un error inesperado"
      return null
    }
  } 

  error = (): boolean => this.errorValidate;
  getError = (): string => this.errors; 
}