import postgres from "postgres";
import { TagRepository } from "../../domain/repositories/TagRepository";
import { Tag, UserTag } from "../../domain/entities/Tag";
import { DBConfig } from "../../../../config/DBConfig";
import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";

export class PostgreSQLTagRepository implements TagRepository{
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
  getAll = async (user_id: number): Promise<string | null | Tag[]> => {
    try{
      const response: Tag[] = await this.postgresConn<Tag[]>`SELECT * FROM financial.sp_tags_get_all(${user_id})`;
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
  /*                             Crea un nuevo tag                              */
  /* -------------------------------------------------------------------------- */
  create = async (tag: UserTag): Promise<Tag|string> => {
    try{
      const response: Tag[] = await this.postgresConn<Tag[]>`SELECT * FROM financial.sp_tags_create(${tag.description}, ${tag.user_id})`;
      return response[0]
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  }
}