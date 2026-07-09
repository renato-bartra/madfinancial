import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/movement_local_dao.dart';
import '../../../../core/services/session_manager.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../infrastructure/datasources/category_remote_data_source.dart';
import '../../infrastructure/datasources/movement_remote_data_source.dart';
import '../../infrastructure/datasources/tag_remote_data_source.dart';
import '../../infrastructure/repositories/category_repository_impl.dart';
import '../../infrastructure/repositories/movement_repository_impl.dart';
import '../../infrastructure/repositories/tag_repository_impl.dart';
import '../controllers/movements_controller.dart';
import '../usecases/create_movement_usecase.dart';
import '../usecases/delete_movement_usecase.dart';
import '../usecases/get_categories_usecase.dart';
import '../usecases/get_movements_by_date_usecase.dart';
import '../usecases/get_tags_usecase.dart';
import '../usecases/update_movement_usecase.dart';

final currentUserIdProvider = FutureProvider<int?>((ref) async {
  return ref.read(sessionManagerProvider).getCurrentUserId();
});

Future<int?> _resolveUserId(Ref ref) async {
  return ref.read(sessionManagerProvider).getCurrentUserId();
}

final movementLocalDaoProvider = Provider<MovementLocalDao>((ref) {
  return MovementLocalDao(ref.watch(localStorageServiceProvider));
});

final movementRemoteDataSourceProvider = Provider<MovementRemoteDataSource>((
  ref,
) {
  return MovementRemoteDataSource(ref.watch(dioProvider));
});

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  return CategoryRemoteDataSource(ref.watch(dioProvider));
});

final tagRemoteDataSourceProvider = Provider<TagRemoteDataSource>((ref) {
  return TagRemoteDataSource(ref.watch(dioProvider));
});

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return MovementRepositoryImpl(
    ref.watch(movementRemoteDataSourceProvider),
    ref.watch(movementLocalDaoProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    ref.watch(categoryRemoteDataSourceProvider),
    ref.watch(movementLocalDaoProvider),
  );
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(
    ref.watch(tagRemoteDataSourceProvider),
    ref.watch(movementLocalDaoProvider),
  );
});

final getMovementsByDateUseCaseProvider = Provider<GetMovementsByDateUseCase>((
  ref,
) {
  return GetMovementsByDateUseCase(ref.watch(movementRepositoryProvider));
});

final createMovementUseCaseProvider = Provider<CreateMovementUseCase>((ref) {
  return CreateMovementUseCase(ref.watch(movementRepositoryProvider));
});

final updateMovementUseCaseProvider = Provider<UpdateMovementUseCase>((ref) {
  return UpdateMovementUseCase(ref.watch(movementRepositoryProvider));
});

final deleteMovementUseCaseProvider = Provider<DeleteMovementUseCase>((ref) {
  return DeleteMovementUseCase(ref.watch(movementRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(
    ref.watch(categoryRepositoryProvider),
    () => _resolveUserId(ref),
  );
});

final getTagsUseCaseProvider = Provider<GetTagsUseCase>((ref) {
  return GetTagsUseCase(
    ref.watch(tagRepositoryProvider),
    () => _resolveUserId(ref),
  );
});

final createTagUseCaseProvider = Provider<CreateTagUseCase>((ref) {
  return CreateTagUseCase(
    ref.watch(tagRepositoryProvider),
    () => _resolveUserId(ref),
  );
});

final categoriesProvider = FutureProvider.autoDispose<List>((ref) async {
  return ref.read(getCategoriesUseCaseProvider).call();
});

final tagsProvider = FutureProvider.autoDispose<List>((ref) async {
  return ref.read(getTagsUseCaseProvider).call();
});

final titleSuggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, categoryId) async {
      return ref
          .read(movementLocalDaoProvider)
          .getTitleSuggestionsByCategory(categoryId);
    });

final movementsControllerProvider =
    NotifierProvider<MovementsController, MovementsState>(
      MovementsController.new,
    );
