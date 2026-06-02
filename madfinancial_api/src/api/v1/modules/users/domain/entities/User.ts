import { Entity } from "../../../shared/domain/entities/Entity";

export interface User extends Entity{
  user_id: number,
  first_name: string,
  last_name: string|null,
  dni: string,
  email: string,
  password: string,
  image: string|null,
}

type Only<T, K extends keyof T> = Pick<T, K>

export type UserID = Only<User, 'user_id'>