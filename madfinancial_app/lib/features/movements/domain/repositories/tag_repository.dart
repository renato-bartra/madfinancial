import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAll(int userId);
  Future<Tag> create(int userId, String description);
}
