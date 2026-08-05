import { Movement, TransferMovement } from "../../domain/entities/Movement";
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

  private exists = async (movementId: number): Promise<boolean | string> => {
    try {
      const response = await this.postgresConn<{ movement_id: number }[]>`
        SELECT movement_id
        FROM financial.vw_movements
        WHERE movement_id = ${movementId}
      `;
      return response.length > 0;
    } catch (err) {
      if (err instanceof Error) {
        return err.message;
      }
      return "Hubo un error inesperado al validar el movimiento ya que no se encuentra en la base de datos";
    }
  };

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
      
      // Cast to corect type and format the values that should be numer
      response[0].movement_id = Number(response[0].movement_id)
      response[0].user_id = Number(response[0].user_id)
      response[0].amount = Number(response[0].amount)
      // response[0].accounting_date = (response[0].accounting_date as any).toISOString().split("T")[0];

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

      return response.map(r => ({
          ...r,
          movement_id: Number(r.movement_id),
          user_id: Number(r.user_id),
          amount: Number(r.amount),
      }));
    } catch (err) {
      if (err instanceof Error) {
        return err.message;
      }
      return "Hubo un error inesperado al obtener los movimientos";
    }
  };

  update = async (movementId: number, movement: Movement): Promise<Movement | string | null> => {
    const exists = await this.exists(movementId);
    if (typeof exists === "string") return exists;
    if (!exists) return null;

    try {
      const response = await this.postgresConn<Movement[]>`
        SELECT * FROM financial.sp_movements_update(
          ${movementId},
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
        return null;
      }

      // Cast to corect type and format the values that should be numer
      response[0].movement_id = Number(response[0].movement_id)
      response[0].user_id = Number(response[0].user_id)
      response[0].amount = Number(response[0].amount)
      // response[0].accounting_date = (response[0].accounting_date as any).toISOString().split("T")[0];

      return response[0] as Movement;
    } catch (err) {
      if (err instanceof Error) {
        return err.message;
      }
      return "Hubo un error inesperado al actualizar el movimiento";
    }
  };

  delete = async (movementId: number): Promise<boolean | string> => {
    const exists = await this.exists(movementId);
    if (typeof exists === "string") return exists;
    if (!exists) return false;

    try {
      const response = await this.postgresConn<{ sp_movements_delete: number }[]>`
        SELECT * FROM financial.sp_movements_delete(${movementId})
      `;

      if (!response.length || response[0].sp_movements_delete != movementId) {
        return false;
      }

      return true;
    } catch (err) {
      if (err instanceof Error) {
        return err.message;
      }
      return "Hubo un error inesperado al eliminar el movimiento";
    }
  };

  createTransfer = async (movement: TransferMovement): Promise<Movement[]> => {
    try {
      const response = await this.postgresConn<Movement[]>`
        SELECT * FROM financial.sp_transfer_movement_create(
          ${movement.user_id},
          ${movement.account_in.account_id},
          ${movement.account_out.account_id},
          ${movement.title},
          ${movement.amount},
          ${movement.description},
          ${movement.accounting_date},
          ${this.postgresConn.json(movement.tags as JSONValue)} :: JSONB
        )
      `;

      if (!response.length || !response[0]) {
        throw new DataBaseException("Error al crear los movimientos de salida e ingreso por transferencia");
      }
      
      // Cast to corect type and format the values that should be numer
      response[0].movement_id = Number(response[0].movement_id)
      response[1].movement_id = Number(response[1].movement_id)
      response[0].user_id = Number(response[0].user_id)
      response[1].user_id = Number(response[1].user_id)
      response[0].amount = Number(response[0].amount)
      response[1].amount = Number(response[1].amount)
      // response[0].accounting_date = (response[0].accounting_date as any).toISOString().split("T")[0];

      return response as Movement[];
    } catch (err) {
      if (err instanceof Error) {
        throw new DataBaseException(err.message);
      }
      throw new Error("Hubo un error inesperado");
    }
  };

  updateTransfer = async (movement: TransferMovement): Promise<Movement[]> => {
    try {
      const response = await this.postgresConn<Movement[]>`
        SELECT * FROM financial.sp_transfer_movement_update(
          ${movement.user_id},
          ${movement.transfer_uuid},
          ${movement.account_in.account_id},
          ${movement.account_out.account_id},
          ${movement.title},
          ${movement.amount},
          ${movement.description},
          ${movement.accounting_date},
          ${this.postgresConn.json(movement.tags as JSONValue)} :: JSONB
        )
      `;

      if (!response.length || !response[0]) {
        throw new DataBaseException("Error al actualizar los movimientos de salida e ingreso por transferencia");
      }
      
      // Cast to corect type and format the values that should be numer
      response[0].movement_id = Number(response[0].movement_id)
      response[1].movement_id = Number(response[1].movement_id)
      response[0].user_id = Number(response[0].user_id)
      response[1].user_id = Number(response[1].user_id)
      response[0].amount = Number(response[0].amount)
      response[1].amount = Number(response[1].amount)
      // response[0].accounting_date = (response[0].accounting_date as any).toISOString().split("T")[0];

      return response as Movement[];
    } catch (err) {
      if (err instanceof Error) {
        throw new DataBaseException(err.message);
      }
      throw new Error("Hubo un error inesperado");
    }
  };

  existsTransfer = async (transfer_uuid: string): Promise<boolean> => {
    try {
      const response = await this.postgresConn<{ movement_id: number }[]>`
        SELECT movement_id
        FROM financial.t_movements
        WHERE transfer_uuid = ${transfer_uuid}
        AND active = TRUE;
      `;
      return response.length > 0;
    } catch (err) {
      if (err instanceof Error) {
        throw new DataBaseException(err.message);
      }
      throw new Error("Hubo un error inesperado al validar la existencia de la transferencia");
    }
  };

  deleteTransfer = async (transfer_uuid: string): Promise<boolean> => {
    try {
      await this.postgresConn<{ sp_movements_delete: number }[]>`
        SELECT * FROM financial.sp_transfer_movement_delete(${transfer_uuid})
      `;

      return true;
    } catch (err) {
      if (err instanceof Error) {
        throw new DataBaseException(err.message);
      }
      throw new Error("Hubo un error inesperado al eliminar el movimiento");
    }
  }
}
