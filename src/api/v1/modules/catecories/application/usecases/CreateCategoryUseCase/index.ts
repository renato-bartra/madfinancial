import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Category, UserCategory } from "../../../domain/entities/Category";
import { CategoryRepository } from "../../../domain/repositories/CategoryRepository";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";

export class CreateCategoryUseCase {
  constructor(
    private readonly categoryRepository: CategoryRepository,
    private validatorManager: ValidatorManager
  ) {}

  create = async (userCategory: UserCategory): Promise<Category> => {
    await this.validatorManager.validate(userCategory);
    if (this.validatorManager.error()) 
      throw new DataValidationException(this.validatorManager.getErrors());
    const createdCategory: Category | string = await this.categoryRepository.create(userCategory);
    if (typeof createdCategory === "string") 
      throw new DataBaseException(createdCategory);
    return createdCategory;
  };
}