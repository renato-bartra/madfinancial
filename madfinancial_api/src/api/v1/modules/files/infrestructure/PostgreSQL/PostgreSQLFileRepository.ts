import postgres, { JSONValue } from "postgres";
import { DBConfig } from "../../../../config/DBConfig";
import { FileRepository } from "../../domain/repositories/FileRepository";
import { DBImportMovement } from "../../domain/entities/ImportMovement";
import { Type } from "../../domain/entities/Type";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";

export class PostgreSQLFileRepository implements FileRepository{
  private readonly dbConfig: DBConfig = new DBConfig();
  private readonly postgresConn = postgres({
    host: this.dbConfig.postgreSQLConn.host,
    port: this.dbConfig.postgreSQLConn.port,
    database: this.dbConfig.postgreSQLConn.database,
    username: this.dbConfig.postgreSQLConn.user,
    password: this.dbConfig.postgreSQLConn.password,
  });
  /* -------------------------------------------------------------------------- */
  /*                     Cnsigue todos los tags de un usuario                   */
  /* -------------------------------------------------------------------------- */
  import = async (user_id: number, movements: DBImportMovement[]): Promise<Boolean> => {
    try{
      await this.postgresConn
        `SELECT * FROM financial.sp_import_movements(
          ${user_id}:: BIGINT, 
          ${this.postgresConn.json(movements as unknown as JSONValue)}::JSONB
        )`;
      return true
    }catch(err){
      if (err instanceof Error){
        return false
      }
      return false
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                     Cnsigue todos los tags de un usuario                   */
  /* -------------------------------------------------------------------------- */
  getTypes = async (user_id: number): Promise<Type[]> => {
    try{
      const response: Type[] = await this.postgresConn<Type[]>`SELECT * FROM financial.sp_types_get_all(${user_id})`;
      if (!response.length)
        throw new EntityNotFoundException()
      return response.map(r => ({
          ...r,
          type_id: Number(r.type_id)
      }));
    }catch(err){
      throw new Error("Hubo un error inesperado")
    }
  };
}