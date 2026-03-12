import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { User } from "../../../domain/entities/User";
import { UserRepository } from "../../../domain/repositories/UserRepository";

export class GetAllUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  get = async (): Promise<User[]> => {
    const data: User[] | null | string = await this.userRepository.getAll();
    if (typeof data === "string") throw new DataBaseException(data);
    return data;
  };
}
