import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Category } from "../../../domain/entities/Category";
import { CategoryRepository } from "../../../domain/repositories/CategoryRepository";

export class GetAllUseCase {
  constructor(private readonly categoryRepository: CategoryRepository) {}

  get = async (user_id: number): Promise<Category[]> => {
    const data: Category[] | null | string = await this.categoryRepository.getAll(user_id);
    if (data == null) throw new EntityNotFoundException()
    if (typeof data === "string") throw new DataBaseException(data);
    return data;
  };
}