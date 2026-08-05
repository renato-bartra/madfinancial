import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { MovementRepository } from "../../domain/repositories/MovementRepository";
import { PostgreSQLMovementRepository } from "../../infraestructure/PostgreSQL/PostgreSQLMovementRepository";
import { ZodMovementValidator } from "../../infraestructure/Zod/ZodMovementValidator";
import { CreateMovementUseCase } from "../usecases/CreateMovementUseCase";
import { DeleteMovementUseCase } from "../usecases/DeleteMovementUseCase";
import { GetByMonthUseCase } from "../usecases/GetByMonthUseCase";
import { UpdateMovementUseCase } from "../usecases/UpdateMovementUseCase";
import { BusinessValidationException } from "../../../shared/domain/exeptions/BusinessValidationException";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";
import { Movement, TransferMovement } from "../../domain/entities/Movement";
import { CreateTransferUseCase } from "../usecases/CreateTransferUseCase";
import { UpdateTransferUseCase } from "../usecases/UpdateTransferUseCase";
import { DeleteTransferUseCase } from "../usecases/DeleteTransferUseCase";
import { ZodTransferMovementValidator } from "../../infraestructure/Zod/ZodTransferMovementValidator";

export class MovementController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private readonly movementRepository: MovementRepository = new PostgreSQLMovementRepository();
  private readonly validatorManager: ValidatorManager = new ZodMovementValidator();
  private readonly transferValidator: ValidatorManager = new ZodTransferMovementValidator();

  create = async (movement: Movement, userId: number): Promise<IResponseObject> => {
    const createMovementUseCase = new CreateMovementUseCase(
      this.movementRepository,
      this.validatorManager
    );
    try {
      movement.user_id = userId;
      const movementCreated = await createMovementUseCase.create(movement);
      return this.data = {
        code: 200,
        message: "Movimiento creado correctamente",
        body: movementCreated,
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        return this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof BusinessValidationException) {
        return this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  };

  getByMonth = async (userId: number, date: string): Promise<IResponseObject> => {
    const getByMonthUseCase = new GetByMonthUseCase(this.movementRepository);
    try {
      const movements = await getByMonthUseCase.get(userId, date);
      return this.data = {
        code: 200,
        message: "",
        body: movements,
      };
    } catch (error) {
      if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  };

  update = async (movementId: number, movement: Movement, userId: number): Promise<IResponseObject> => {
    const updateMovementUseCase = new UpdateMovementUseCase(
      this.movementRepository,
      this.validatorManager
    );
    try {
      movement.user_id = userId;
      const movementUpdated = await updateMovementUseCase.update(movementId, movement);
      return this.data = {
        code: 200,
        message: "Updated Movement",
        body: movementUpdated,
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        return this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof BusinessValidationException) {
        return this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else if (error instanceof EntityNotFoundException) {
        return this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  };

  delete = async (movementId: number): Promise<IResponseObject> => {
    const deleteMovementUseCase = new DeleteMovementUseCase(this.movementRepository);
    try {
      await deleteMovementUseCase.delete(movementId);
      return this.data = {
        code: 200,
        message: "Deleted Movement",
        body: [],
      };
    } catch (error) {
      if (error instanceof EntityNotFoundException) {
        return this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  };

  createTransfer = async (transfer: TransferMovement, user_id: number): Promise<IResponseObject> => {
    const createTransferUseCase = new CreateTransferUseCase(
      this.movementRepository,
      this.transferValidator
    );
    try {
      transfer.user_id = user_id;
      const transferCreated: Movement[] = await createTransferUseCase.create(transfer);
      
      return this.data = {
        code: 200,
        message: "Transferencia creada correctamente",
        body: transferCreated
      } 
    } catch (error) {
      if (error instanceof DataValidationException) {
        return this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  };

  updateTransfer = async (transfer: TransferMovement, transfer_uuid: string, user_id: number): Promise<IResponseObject> => {
    const updateTransferUseCase = new UpdateTransferUseCase(
      this.movementRepository,
      this.transferValidator
    );
    try {
      transfer.user_id = user_id;
      transfer.transfer_uuid = transfer_uuid;
      const transferCreated: Movement[] = await updateTransferUseCase.update(transfer);
      
      return this.data = {
        code: 200,
        message: "Transferencia creada correctamente",
        body: transferCreated
      } 
    } catch (error) {
      if (error instanceof DataValidationException) {
        return this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof EntityNotFoundException) {
        return this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  };

  deleteTransfer = async (transfer_uuid: string): Promise<IResponseObject> => {
    const deleteTransferUseCase = new DeleteTransferUseCase(this.movementRepository);
    try {
      await deleteTransferUseCase.delete(transfer_uuid);
      return this.data = {
        code: 200,
        message: "Transferencia eliminada",
        body: [],
      };
    } catch (error) {
      if (error instanceof EntityNotFoundException) {
        return this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else if (error instanceof DataBaseException) {
        return this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  }
}
