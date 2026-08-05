import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { Movement, TransferMovement } from "../../../domain/entities/Movement";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";

export class CreateTransferUseCase {
  constructor(
    private readonly movementRepository: MovementRepository,
    private readonly validatorManager: ValidatorManager
  ) {}

  create = async (transfer: TransferMovement): Promise<Movement[]> => {
    await this.validatorManager.validate(transfer);
    if (this.validatorManager.error()) {
      throw new DataValidationException(this.validatorManager.getErrors());
    }
    
    const createdTransfer: Movement[] = await this.movementRepository.createTransfer(transfer);

    return createdTransfer;
  }
}