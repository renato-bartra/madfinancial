import { DomainRepository } from "../../../shared/domain/repositories/DomainRepository";
import { User } from "../entities/User";

export interface UserRepository extends DomainRepository{
  getAll: () => Promise<User[]|string>;
  create: (user: User) => Promise<User|string>;
  getByEmail: (email: string) => Promise<User | string | null>;
  getById: (id: number) => Promise<User | string | null>;
  update: (id: number, user: User) => Promise<User|string|null>;
  delete: (id: number) => Promise<boolean|string>;
}