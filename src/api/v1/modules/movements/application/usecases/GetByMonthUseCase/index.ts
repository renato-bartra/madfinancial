import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Movement } from "../../../domain/entities/Movement";
import { MovementRepository } from "../../../domain/repositories/MovementRepository";

export class GetByMonthUseCase {
  constructor(private readonly movementRepository: MovementRepository) {}

  get = async (userId: number, date: string): Promise<Movement[]> => {
    const movements = await this.movementRepository.getByMonth(userId, date);
    if (typeof movements === "string") {
      throw new DataBaseException(movements);
    }
    return movements;
  };
}
