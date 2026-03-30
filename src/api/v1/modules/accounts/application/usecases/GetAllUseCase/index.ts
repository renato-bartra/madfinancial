import { EntityNotFoundException } from "../../../../shared/domain/exeptions/EntityNotFoundException";
import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Account } from "../../../domain/entities/Account";
import { AccountRepository } from "../../../domain/repositories/AccountRepository";

export class GetAllUseCase {
  constructor(private readonly accountRepository: AccountRepository) {}

  get = async (user_id: number): Promise<Account[]> => {
    const data: Account[] | null | string = await this.accountRepository.getAll(user_id);
    if (data == null) throw new EntityNotFoundException()
    if (typeof data === "string") throw new DataBaseException(data);
    return data;
  };
}