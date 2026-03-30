import { Account, UserAccount } from "../entities/Account";

export interface AccountRepository{
  getAll: (user_id: number) => Promise<Account[]| null |string>;
  create: (user_tag: UserAccount) => Promise<Account|string>;
}