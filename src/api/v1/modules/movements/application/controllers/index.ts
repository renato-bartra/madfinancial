import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { MovementRepository } from "../../domain/repositories/MovementRepository";
import { PostgreSQLMovementRepository } from "../../infraestructure/PostgreSQL/PostgreSQLMovementRepository";
import { ZodMovementValidator } from "../../infraestructure/Zod/ZodMovementValidator";
import { CreateMovementUseCase } from "../usecases/CreateMovementUseCase";
import { GetByMonthUseCase } from "../usecases/GetByMonthUseCase";
import { BusinessValidationException } from "../../../shared/domain/exeptions/BusinessValidationException";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";
import { Movement } from "../../domain/entities/Movement";

export class MovementController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private readonly movementRepository: MovementRepository = new PostgreSQLMovementRepository();
  private readonly validatorManager: ValidatorManager = new ZodMovementValidator();

  create = async (movement: Movement, userId: number): Promise<IResponseObject> => {
    const createMovementUseCase = new CreateMovementUseCase(
      this.movementRepository,
      this.validatorManager
    );
    try {
      movement.user_id = userId;
      const movementCreated = await createMovementUseCase.create(movement);
      this.data = {
        code: 200,
        message: "Movimiento creado correctamente",
        body: movementCreated,
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof BusinessValidationException) {
        this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else if (error instanceof DataBaseException) {
        this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };

  getByMonth = async (userId: number, date: string): Promise<IResponseObject> => {
    const getByMonthUseCase = new GetByMonthUseCase(this.movementRepository);
    try {
      const movements = await getByMonthUseCase.get(userId, date);
      this.data = {
        code: 200,
        message: "",
        body: movements,
      };
    } catch (error) {
      if (error instanceof DataBaseException) {
        this.data = {
          code: 500,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
}
