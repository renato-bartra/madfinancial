import { DataBaseException } from "../../../../shared/domain/exeptions/DataBaseException";
import { Account, UserAccount } from "../../../domain/entities/Account";
import { AccountRepository } from "../../../domain/repositories/AccountRepository";
import { ValidatorManager } from "../../../../shared/domain/repositories/ValidatorManager";
import { DataValidationException } from "../../../../shared/domain/exeptions/DataValidationException";

export class CreateAccountUseCase {
  constructor(
    private readonly accountRepository: AccountRepository,
    private validatorManager: ValidatorManager
  ) {}

  create = async (userAccount: UserAccount): Promise<Account> => {
    await this.validatorManager.validate(userAccount);
    if (this.validatorManager.error()) 
      throw new DataValidationException(this.validatorManager.getErrors());
    const createdAccount: Account | string = await this.accountRepository.create(userAccount);
    if (typeof createdAccount === "string") 
      throw new DataBaseException(createdAccount);
    return createdAccount;
  };
}