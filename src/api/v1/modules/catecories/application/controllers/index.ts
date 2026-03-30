import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { Category, UserCategory } from "../../domain/entities/Category";
import { CategoryRepository } from "../../domain/repositories/CategoryRepository";
import { PostgreSQLCategoryRepository } from "../../infraestructure/PostgreSQL/PostgreSQLCategoryRepository";
import { ZodCategoryValidator } from "../../infraestructure/Zod/ZodCategoryValidator";
import { CreateCategoryUseCase } from "../usecases/CreateCategoryUseCase";
import { GetAllUseCase } from "../usecases/GetAllUseCase";

export class CategoryController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private categoryRepository : CategoryRepository = new PostgreSQLCategoryRepository();
  private validatorManager: ValidatorManager = new ZodCategoryValidator();

  /* -------------------------------------------------------------------------- */
  /*                   Consigue todos los categorías de un usuarios                   */
  /* -------------------------------------------------------------------------- */
  getAll = async (user_id: number): Promise<IResponseObject> => {
    let getAllCategories = new GetAllUseCase(this.categoryRepository);
    try {
      let reponse: Category[] = await getAllCategories.get(user_id);
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
  /*                      Crea un nuevo category de un usuarios                      */
  /* -------------------------------------------------------------------------- */
  create = async (userCategory: UserCategory): Promise<IResponseObject> => {
    let categoryCreator = new CreateCategoryUseCase(this.categoryRepository, this.validatorManager);
    try {
      let createdCategory = await categoryCreator.create(userCategory);
      this.data = {
        code: 200,
        message: "",
        body: createdCategory
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