import { Entity } from "../entities/Entity";

export interface DomainRepository {
  getAll: () => Promise<Entity[]|any>;
  create: (entity: Entity|any) => Promise<Entity|any>;
  getById: (id: number) => Promise<Entity | any>;
  update: (id: number, entity: Entity|any) => Promise<Entity|any>;
  delete: (id: number) => Promise<boolean|any>;
}