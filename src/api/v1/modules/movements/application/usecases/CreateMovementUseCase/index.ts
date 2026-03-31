import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";
import { BusinessValidationException } from "../../../../shared/domain/exeptions/BusinessValidationException";
import { Movement } from "../../../domain/entities/Movement";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";

export class CreateMovementUseCase {
  constructor(
    private readonly movementRepository: MovementRepository,
    private readonly validatorManager: ValidatorManager
  ) {}

  create = async (movement: Movement): Promise<Movement> => {
    await this.validatorManager.validate(movement);
    if (this.validatorManager.error()) {
      throw new DataValidationException(this.validatorManager.getErrors());
    }

    if (movement.submovements && movement.submovements.length > 0) {
      const submovementSum = movement.submovements.reduce(
        (sum, submovement) => sum + submovement.amount,
        0
      );
      if (submovementSum !== movement.amount) {
        throw new BusinessValidationException(
          `La suma de los submovimientos (${submovementSum}) debe ser igual al monto del movimiento (${movement.amount})`
        );
      }
    }

    const movementCreated = await this.movementRepository.create(movement);
    if (typeof movementCreated === "string") {
      throw new DataBaseException(movementCreated);
    }

    return movementCreated;
  };
}
