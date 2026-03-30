import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { Tag, UserTag } from "../../domain/entities/Tag";
import { TagRepository } from "../../domain/repositories/TagRepository";
import { PostgreSQLTagRepository } from "../../infraestructure/PostgreSQL/PostgreSQLTagRepository";
import { ZodTagValidator } from "../../infraestructure/Zod/ZodTagValidator";
import { CreateTagUseCase } from "../usecases/CreateTagUseCase";
import { GetAllUseCase } from "../usecases/GetAllUseCase";

export class TagController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private tagRepository : TagRepository = new PostgreSQLTagRepository();
  private validatorManager: ValidatorManager = new ZodTagValidator();

  /* -------------------------------------------------------------------------- */
  /*                   Consigue todos los tags de un usuarios                   */
  /* -------------------------------------------------------------------------- */
  getAll = async (user_id: number): Promise<IResponseObject> => {
    let getAllTags = new GetAllUseCase(this.tagRepository);
    try {
      let reponse: Tag[] = await getAllTags.get(user_id);
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
  /*                      Crea un nuevo tag de un usuarios                      */
  /* -------------------------------------------------------------------------- */
  create = async (userTag: UserTag): Promise<IResponseObject> => {
    let tagCreator = new CreateTagUseCase(this.tagRepository, this.validatorManager);
    try {
      let createdTag = await tagCreator.create(userTag);
      this.data = {
        code: 200,
        message: "",
        body: createdTag
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