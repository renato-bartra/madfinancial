import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

class GetTagsUseCase {
  const GetTagsUseCase(this._repository, this._resolveUserId);

  final TagRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<List<Tag>> call() async {
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.getAll(userId);
  }
}

class CreateTagUseCase {
  const CreateTagUseCase(this._repository, this._resolveUserId);

  final TagRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<Tag> call(String description) async {
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.create(userId, description);
  }
}

class _NoSessionException implements Exception {
  const _NoSessionException();
  @override
  String toString() => 'No hay sesión activa.';
}
