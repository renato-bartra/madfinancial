import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../infrastructure/datasources/movement_remote_data_source.dart';
import '../../infrastructure/repositories/movement_repository_impl.dart';
import '../controllers/movements_controller.dart';
import '../usecases/get_movements_by_date_usecase.dart';

final movementRemoteDataSourceProvider = Provider<MovementRemoteDataSource>((
  ref,
) {
  return MovementRemoteDataSource(ref.watch(dioProvider));
});

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return MovementRepositoryImpl(ref.watch(movementRemoteDataSourceProvider));
});

final getMovementsByDateUseCaseProvider = Provider<GetMovementsByDateUseCase>((
  ref,
) {
  return GetMovementsByDateUseCase(ref.watch(movementRepositoryProvider));
});

final movementsControllerProvider =
    NotifierProvider<MovementsController, MovementsState>(
      MovementsController.new,
    );
