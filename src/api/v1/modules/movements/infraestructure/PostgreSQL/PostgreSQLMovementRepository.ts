import { Movement } from "../../domain/entities/Movement";
import { MovementRepository } from "../../domain/repositories/MovementRepository";
import { DBConfig } from "../../../../config/DBConfig";
import postgres, { JSONValue } from "postgres";
import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";

export class PostgreSQLMovementRepository implements MovementRepository {
  private readonly dbConfig: DBConfig = new DBConfig();
  private readonly postgresConn = postgres({
    host: this.dbConfig.postgreSQLConn.host,
    port: this.dbConfig.postgreSQLConn.port,
    database: this.dbConfig.postgreSQLConn.database,
    username: this.dbConfig.postgreSQLConn.user,
    password: this.dbConfig.postgreSQLConn.password,
  });

  create = async (movement: Movement): Promise<Movement | string> => {
    try {
        
      const response = await this.postgresConn<Movement[]>`
        SELECT * FROM financial.sp_movements_create(
          ${movement.user_id},
          ${movement.type.type_id},
          ${movement.category.category_id},
          ${movement.account.account_id},
          ${movement.title},
          ${movement.amount},
          ${movement.description},
          ${movement.accounting_date},
          ${this.postgresConn.json(movement.tags as JSONValue)} :: JSONB,
          ${this.postgresConn.json(movement.submovements as JSONValue)} :: JSONB
        )
      `;

      if (!response.length || !response[0]) {
        throw new DataBaseException("Error al crear el movimiento");
      }

      return response[0] as Movement;
    } catch (err) {
      if (err instanceof Error) {
        return err.message;
      }
      return "Hubo un error inesperado al crear el movimiento";
    }
  };

  getByMonth = async (userId: number, date: string): Promise<Movement[] | string> => {
    try {
      const response = await this.postgresConn<Movement[]>`
        SELECT * FROM financial.sp_get_all_movements_by_user_and_date(
          ${userId},
          ${date}
        )
      `;

      if (!response.length) {
        return [];
      }

      return response as Movement[];
    } catch (err) {
      if (err instanceof Error) {
        return err.message;
      }
      return "Hubo un error inesperado al obtener los movimientos";
    }
  };
}
