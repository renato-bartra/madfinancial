import '../../../../core/services/movement_local_dao.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../mappers/movement_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remoteDataSource, this._localDao);

  final CategoryRemoteDataSource _remoteDataSource;
  final MovementLocalDao _localDao;

  @override
  Future<List<Category>> getAll(int userId) async {
    final local = await _localDao.getAllCategories();
    if (local.isNotEmpty) return local;

    final dtos = await _remoteDataSource.getAll(userId);
    final categories = dtos.map((dto) => dto.toEntity()).toList();
    await _localDao.saveAllCategories(categories);
    return categories;
  }
}
