import { parse } from "csv-parse/sync";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { FileRepository } from "../../domain/repositories/FileRepository";
import { PostgreSQLFileRepository } from "../../infrestructure/PostgreSQL/PostgreSQLFileRepository";
import { ImportFileUseCase } from "../usecases/ImportFileUseCase";
import { CategoryRepository } from "../../../catecories/domain/repositories/CategoryRepository";
import { PostgreSQLCategoryRepository } from "../../../catecories/infraestructure/PostgreSQL/PostgreSQLCategoryRepository";
import { AccountRepository } from "../../../accounts/domain/repositories/AccountRepository";
import { PostgreSQLAccountRepository } from "../../../accounts/infraestructure/PostgreSQL/PostgreSQLAccountRepository";
import { ImportMovement } from "../../domain/entities/ImportMovement";

export class FileController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  private readonly fileRepository: FileRepository = new PostgreSQLFileRepository();
  private readonly categoryRepository: CategoryRepository = new PostgreSQLCategoryRepository();
  private readonly accountRepository: AccountRepository = new PostgreSQLAccountRepository();

  import = async (userId: number, file: Buffer): Promise<IResponseObject> => {
    try{
      //Leer CSV
      const importMovements: ImportMovement[] = parse(file, {
        columns: true,
        delimiter: ",",
        skip_empty_lines: true,
      });
      const fileImporter = new ImportFileUseCase(this.fileRepository, this.categoryRepository, this.accountRepository);
      await fileImporter.import(userId, importMovements)

      return this.data = {
        code: 200,
        message: "El archivo se importó correctamente, por favor vuelva a ingrasar a la app",
        body: []
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        // aqui formatea los errores de fileSaver.getErrors()
        return this.data = {
          code: 404,
          message: "Los datos enviados no tienen el formato requerido",
          body: [error.getErrors],
        };
      }else {
        return this.data = {
          code: 500,
          message: "Uno un error al guardar el archivo",
          body: [],
        };
      }
    }
  }
}