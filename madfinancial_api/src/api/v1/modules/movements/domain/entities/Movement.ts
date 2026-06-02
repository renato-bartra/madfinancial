import { Account } from "../../../accounts/domain/entities/Account";
import { Category } from "../../../catecories/domain/entities/Category";
import { Entity } from "../../../shared/domain/entities/Entity";
import { Tag } from "../../../tags/domain/entities/Tag";

export interface MovementType extends Entity {
  type_id: number;
  description: string;
}

export interface Submovement extends Entity {
  submovement_id: number;
  description: string;
  amount: number;
  subcategory: Category;
  tags: Tag[] | [];
}

export interface Movement extends Entity {
  movement_id: number;
  user_id: number;
  title: string;
  description: string;
  amount: number;
  accounting_date: string;
  type: MovementType;
  category: Category;
  account: Account;
  tags: Tag[] | [];
  submovements: Submovement[] | [];
}
