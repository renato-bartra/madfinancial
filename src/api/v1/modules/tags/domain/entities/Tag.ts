import { Entity } from "../../../shared/domain/entities/Entity";

export interface Tag extends Entity{
  tag_id: number,
  description: string
}

type Append<T, U> = T & U;

export type UserTag = Append<Tag, { user_id: number }>