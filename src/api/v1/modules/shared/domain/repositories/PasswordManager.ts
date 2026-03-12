export interface PasswordManager{
  encrypt: (password: string) => Promise<string>;
  decrypt: (password: string, hashed: string) => Promise<boolean>;
}