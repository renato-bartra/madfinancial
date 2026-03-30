import { Tag, UserTag } from "../entities/Tag";

export interface TagRepository{
  getAll: (user_id: number) => Promise<Tag[]| null |string>;
  create: (user_tag: UserTag) => Promise<Tag|string>;
}