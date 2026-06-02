import { Category, UserCategory } from "../entities/Category";

export interface CategoryRepository{
  getAll: (user_id: number) => Promise<Category[]| null |string>;
  create: (user_tag: UserCategory) => Promise<Category|string>;
}