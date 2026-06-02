import postgres from "postgres";
import { DBConfig } from "../../../../config/DBConfig";
import { CategoryRepository } from "../../domain/repositories/CategoryRepository";
import { Category, UserCategory } from "../../domain/entities/Category";

export class PostgreSQLCategoryRepository implements CategoryRepository{
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
  getAll = async (user_id: number): Promise<string | null | Category[]> => {
    try{
      const response: Category[] = await this.postgresConn<Category[]>`SELECT * FROM financial.sp_categories_get_all(${user_id})`;
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
  /*                          Crea una nueva category                           */
  /* -------------------------------------------------------------------------- */
  create = async (category: UserCategory): Promise<Category|string> => {
    try{
      const response: Category[] = await this.postgresConn<Category[]>`SELECT * FROM financial.sp_categories_create(${category.description}, ${category.category_type}, ${category.user_id})`;
      return response[0]
    }catch(err){
      if (err instanceof Error){
        return err.message
      }
      return "Hubo un error inesperado"
    }
  }
}