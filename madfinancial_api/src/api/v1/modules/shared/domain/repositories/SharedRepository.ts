import { User } from "../../../users/domain/entities/User";

export interface SharedRepository {
  changePassword: (id: number,password: string) => Promise<boolean>;
  getByEmail: (email: string) => Promise<User | null>
  error: () => boolean;
  getError: () => string;
}