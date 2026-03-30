import { Entity } from "../../../shared/domain/entities/Entity";

export interface Category extends Entity{
  category_id: number,
  category_type: boolean,
  description: string
}

type Append<T, U> = T & U;

export type UserCategory = Append<Category, { user_id: number }>