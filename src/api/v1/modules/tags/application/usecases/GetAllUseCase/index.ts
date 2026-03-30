import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Tag } from "../../../domain/entities/Tag";
import { TagRepository } from "../../../domain/repositories/TagRepository";

export class GetAllUseCase {
  constructor(private readonly tagRepository: TagRepository) {}

  get = async (user_id: number): Promise<Tag[]> => {
    const data: Tag[] | null | string = await this.tagRepository.getAll(user_id);
    if (data == null) throw new EntityNotFoundException()
    if (typeof data === "string") throw new DataBaseException(data);
    return data;
  };
}