
import { DBImportMovement } from "../entities/ImportMovement";
import { Type } from "../entities/Type";

export interface FileRepository{
  import: (user_id: number, movements: DBImportMovement[]) => Promise<Boolean>;
  getTypes: (user_id: number) => Promise<Type[]>;
}