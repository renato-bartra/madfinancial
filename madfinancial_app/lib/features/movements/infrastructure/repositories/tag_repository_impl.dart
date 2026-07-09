import '../../../../core/services/movement_local_dao.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_remote_data_source.dart';
import '../mappers/movement_mapper.dart';

class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl(this._remoteDataSource, this._localDao);

  final TagRemoteDataSource _remoteDataSource;
  final MovementLocalDao _localDao;

  @override
  Future<List<Tag>> getAll(int userId) async {
    final local = await _localDao.getAllTags();
    if (local.isNotEmpty) return local;

    final dtos = await _remoteDataSource.getAll(userId);
    final tags = dtos.map((dto) => dto.toEntity()).toList();
    await _localDao.saveAllTags(tags);
    return tags;
  }

  @override
  Future<Tag> create(int userId, String description) async {
    final tagId = DateTime.now().millisecondsSinceEpoch;
    final dto = await _remoteDataSource.create(
      userId: userId,
      tagId: tagId,
      description: description,
    );
    final tag = dto.toEntity();
    await _localDao.saveTag(tag);
    return tag;
  }
}
