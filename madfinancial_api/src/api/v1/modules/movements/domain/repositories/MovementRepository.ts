import { Movement, TransferMovement } from "../entities/Movement";

export interface MovementRepository {
  create: (movement: Movement) => Promise<Movement | string>;
  getByMonth: (userId: number, date: string) => Promise<Movement[] | string>;
  update: (movementId: number, movement: Movement) => Promise<Movement | string | null>;
  delete: (movementId: number) => Promise<boolean | string>;
  createTransfer: (movement: TransferMovement) => Promise<Movement[]>;
  updateTransfer: (movement: TransferMovement) => Promise<Movement[]>;
  deleteTransfer: (transfer_uuid: string) => Promise<boolean>;
  existsTransfer: (transfer_uuid: string) => Promise<boolean>;
}
