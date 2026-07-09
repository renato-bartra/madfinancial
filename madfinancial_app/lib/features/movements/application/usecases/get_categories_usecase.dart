import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository, this._resolveUserId);

  final CategoryRepository _repository;
  final Future<int?> Function() _resolveUserId;

  Future<List<Category>> call() async {
    final userId = await _resolveUserId();
    if (userId == null) {
      throw const _NoSessionException();
    }
    return _repository.getAll(userId);
  }
}

class _NoSessionException implements Exception {
  const _NoSessionException();
  @override
  String toString() => 'No hay sesión activa.';
}
