import postgres from "postgres";
import { DBConfig } from "../../../../config/DBConfig";
import { AccountRepository } from "../../domain/repositories/AccountRepository";
import { Account, UserAccount } from "../../domain/entities/Account";

export class PostgreSQLAccountRepository implements AccountRepository{
  private readonly dbConfig: DBConfig = new DBConfig();
  private readonly postgresConn = postgres({
    host: this.dbConfig.postgreSQLConn.host,
    port: this.dbConfig.postgreSQLConn.port,
    database: this.dbConfig.postgreSQLConn.database,
    username: this.dbConfig.postgreSQLConn.user,
    password: this.dbConfig.postgreSQLConn.password,
  });
  /* -------------------------------------------------------------------------- */
  /*                     Cnsigue todos los categories de un usuario                   */
  /* -------------------------------------------------------------------------- */
  getAll = async (user_id: number): Promise<string | null | Account[]> => {
    try{
      const response: Account[] = await this.postgresConn<Account[]>`SELECT * FROM financial.sp_accounts_get_all(${user_id})`;
      if (!response.length)
        return null
      return response;
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                          Crea una nueva Account                            */
  /* -------------------------------------------------------------------------- */
  create = async (account: UserAccount): Promise<Account|string> => {
    try{
      const response: Account[] = await this.postgresConn<Account[]>`SELECT * FROM financial.sp_accounts_create(${account.description}, ${account.user_id})`;
      return response[0]
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  }
}