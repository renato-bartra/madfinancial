import { AccountRepository } from "../../../accounts/domain/repositories/AccountRepository";
import { CategoryRepository } from "../../../catecories/domain/repositories/CategoryRepository";
import { IErrorObject } from "../../../shared/domain/repositories/IErrorObject";
import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { FileRepository } from "../../domain/repositories/FileRepository";
import { DBImportMovement, ImportMovement } from "../../domain/entities/ImportMovement";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";
import { DataBaseException } from "../../../shared/domain/exeptions/DataBaseException";

export class ImportFileUseCase {
  constructor(
    private readonly fileRepository: FileRepository,
    private readonly categoryRepository: CategoryRepository,
    private readonly accountRepository: AccountRepository
  ) {}

  private errorObject: IErrorObject[] = [];

  import = async (userId: number, importMovements: ImportMovement[]): Promise<Boolean> => {

    this.errorObject = [];

    //Get data in parallel form DB 
    const [
      dbTypes,
      dbCategories,
      dbAccounts
    ] = await Promise.all([
      this.fileRepository.getTypes(userId),
      this.categoryRepository.getAll(userId),
      this.accountRepository.getAll(userId),
    ]);

    //Create Sets
    const csvTypes = [...new Set(importMovements.map(x => x.Tipo))];
    const csvCategories = [...new Set(importMovements.map(x => x.Categoria))];
    const csvAccounts = [...new Set(importMovements.map(x => x.Cuenta))];

    const dbTypeMap = new Map(
      dbTypes.map(x => [x.description, x])
    );

    if (dbCategories == null) {throw new EntityNotFoundException()};
    if (typeof dbCategories == "string") {throw new DataBaseException("Hubo un error con la base de datos")};
    const dbCategoryMap = new Map(
      dbCategories.map(x => [x.description, x])
    );

    if (dbAccounts == null) {throw new EntityNotFoundException()};
    if (typeof dbAccounts == "string") {throw new DataBaseException("Hubo un error con la base de datos")};
    const dbAccountMap = new Map(
      dbAccounts.map(x => [x.description, x])
    );

    //Validate Types
    const notFoundTypes = csvTypes.filter(
      x => !dbTypeMap.has(x)
    );

    if (notFoundTypes.length > 0) {
      this.errorObject.push({
        attribute: "Categoría",
        message:
          `Las siguientes tipos no existen en la base de datos: ${notFoundTypes.join(", ")}`
      });
    }

    //Validate Categories
    const notFoundCategories = csvCategories.filter(
      x => !dbCategoryMap.has(x)
    );
    if (notFoundCategories.length > 0) {
      this.errorObject.push({
        attribute: "Categoría",
        message:
          `Las siguientes categorías no existen en la base de datos: ${notFoundCategories.join(", ")}`
      });
    }

    //Validate Accounts
    const notFoundAccounts = csvAccounts.filter(
      x => !dbAccountMap.has(x)
    );
    if (notFoundAccounts.length > 0) {
      this.errorObject.push({
        attribute: "Cuenta",
        message:
          `Las siguientes cuentas no existen en la base de datos: ${notFoundAccounts.join(", ")}`
      });
    }

    if (this.errorObject.length > 0) {
      throw new DataValidationException(this.errorObject);
    }

    const movements: DBImportMovement[] = importMovements.map(item => ({
      type_id: dbTypeMap.get(item.Tipo)!.type_id,
      category_id: dbCategoryMap.get(item.Categoria)!.category_id,
      account_id: dbAccountMap.get(item.Cuenta)!.account_id,
      title: item.Titulo,
      amount: Number(String(item.Monto).replace(/,/g, "")),
      description: item.Descripcion,
      accounting_date: item.Fecha
    }));

    return await this.fileRepository.import(userId, movements);
  };

  getErrors = (): IErrorObject[] => {
    return this.errorObject;
  };

}