import { BusinessValidationException } from "../../../../shared/domain/exeptions/BusinessValidationException";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { Movement } from "../../../domain/entities/Movement";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";

export class UpdateMovementUseCase {
  constructor(
    private readonly movementRepository: MovementRepository,
    private readonly validatorManager: ValidatorManager
  ) {}

  update = async (movementId: number, movement: Movement): Promise<Movement> => {
    movement.movement_id = movementId;

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

    const movementUpdated = await this.movementRepository.update(movementId, movement);
    if (movementUpdated === null) throw new EntityNotFoundException();
    if (typeof movementUpdated === "string") {
      throw new DataBaseException(movementUpdated);
    }

    return movementUpdated;
  };
}
