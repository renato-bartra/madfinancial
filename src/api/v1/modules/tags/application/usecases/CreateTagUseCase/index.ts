import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Tag, UserTag } from "../../../domain/entities/Tag";
import { TagRepository } from "../../../domain/repositories/TagRepository";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";

export class CreateTagUseCase {
  constructor(
    private readonly tagRepository: TagRepository,
    private validatorManager: ValidatorManager
  ) {}

  create = async (userTag: UserTag): Promise<Tag> => {
    await this.validatorManager.validate(userTag);
    if (this.validatorManager.error()) 
      throw new DataValidationException(this.validatorManager.getErrors());
    const createdTag: Tag | string = await this.tagRepository.create(userTag);
    if (typeof createdTag === "string") 
      throw new DataBaseException(createdTag);
    return createdTag;
  };
}