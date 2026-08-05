import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";

export class DeleteTransferUseCase {
  constructor(
    private readonly movementRepository: MovementRepository
  ) {}

  delete = async (transfer_uuid: string): Promise<boolean> => {

    const exists = await this.movementRepository.existsTransfer(transfer_uuid);
    if (!exists) throw new EntityNotFoundException();

    const deletedTransfer: boolean = await this.movementRepository.deleteTransfer(transfer_uuid);

    return deletedTransfer;
  }
}