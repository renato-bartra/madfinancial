import bcrypt from "bcryptjs";
import { PasswordManager } from "../../../domain/repositories/PasswordManager";

export class PasswordBcrypt implements PasswordManager {
  constructor(private readonly salt: number) {}
  // Encripta la contraseña
  encrypt = async (password: string): Promise<string> => {
    let pass: string = bcrypt.hashSync(password, this.salt).toString();
    return pass;
  };
  // Desencripta la contraseña
  decrypt = async (password: string, hashed: string): Promise<boolean> => {
    let comparation: boolean = bcrypt.compareSync(password, hashed);
    return comparation;
  };
}
