import { Entity } from "../../../shared/domain/entities/Entity";

export interface Account extends Entity{
  account_id: number,
  description: string
}

type Append<T, U> = T & U;

export type UserAccount = Append<Account, { user_id: number }>