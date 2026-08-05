import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";
import { Movement, TransferMovement } from "../../../domain/entities/Movement";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";

export class UpdateTransferUseCase {
  constructor(
    private readonly movementRepository: MovementRepository,
    private readonly validatorManager: ValidatorManager
  ) {}

  update = async (transfer: TransferMovement): Promise<Movement[]> => {
    await this.validatorManager.validate(transfer);
    if (this.validatorManager.error()) {
      throw new DataValidationException(this.validatorManager.getErrors());
    }

    const existsTransfer: boolean = await this.movementRepository.existsTransfer(transfer.transfer_uuid)
    if (!existsTransfer) throw new EntityNotFoundException()
    
    const updatedTransfer: Movement[] = await this.movementRepository.updateTransfer(transfer);

    return updatedTransfer;
  }
}