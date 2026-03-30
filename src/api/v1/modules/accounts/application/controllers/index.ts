import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { Account, UserAccount } from "../../domain/entities/Account";
import { AccountRepository } from "../../domain/repositories/AccountRepository";
import { PostgreSQLAccountRepository } from "../../infraestructure/PostgreSQL/PostgreSQLAccountRepository";
import { ZodAccountValidator } from "../../infraestructure/Zod/ZodAccountValidator";
import { CreateAccountUseCase } from "../usecases/CreateAccountUseCase";
import { GetAllUseCase } from "../usecases/GetAllUseCase";

export class AccountController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private accountRepository : AccountRepository = new PostgreSQLAccountRepository();
  private validatorManager: ValidatorManager = new ZodAccountValidator();

  /* -------------------------------------------------------------------------- */
  /*                   Consigue todos los categorías de un usuarios                   */
  /* -------------------------------------------------------------------------- */
  getAll = async (user_id: number): Promise<IResponseObject> => {
    let getAllCategories = new GetAllUseCase(this.accountRepository);
    try {
      let reponse: Account[] = await getAllCategories.get(user_id);
      this.data = {
        code: 200,
        message: "un gran poder conlleva una gran responsabilidad",
        body: reponse
      }
      return this.data
    } catch (error) {
      if (error instanceof EntityNotFoundException){
        return this.data = { code: 404, message: error.message, body: [] };
      }else if (error instanceof DataBaseException){
        return this.data = { code: 500, message: error.message, body: [] };
      }else {
        return this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                      Crea un nuevo Account de un usuarios                      */
  /* -------------------------------------------------------------------------- */
  create = async (userAccount: UserAccount): Promise<IResponseObject> => {
    let accountCreator = new CreateAccountUseCase(this.accountRepository, this.validatorManager);
    try {
      let createdAccount = await accountCreator.create(userAccount);
      this.data = {
        code: 200,
        message: "",
        body: createdAccount
      }
      return this.data
    }catch(err) {
      if (err instanceof DataValidationException)
        {this.data = {code: 404, message: err.message, body:[]}}
      else if (err instanceof DataBaseException)
        {this.data = {code: 400, message: err.message, body:[]}}
      else {this.data = { code: 500, message: `Server error: ${err}`, body: []};}
      return this.data;
    }
  }
}