import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";

export class DeleteMovementUseCase {
  constructor(private readonly movementRepository: MovementRepository) {}

  delete = async (movementId: number): Promise<boolean> => {
    const deleted = await this.movementRepository.delete(movementId);
    if (typeof deleted === "string") throw new DataBaseException(deleted);
    if (deleted === false) throw new EntityNotFoundException();
    return deleted;
  };
}
