import { Movement } from "../entities/Movement";

export interface MovementRepository {
  create: (movement: Movement) => Promise<Movement | string>;
  getByMonth: (userId: number, date: string) => Promise<Movement[] | string>;
}
