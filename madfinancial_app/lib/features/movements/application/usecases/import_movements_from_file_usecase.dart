import '../../domain/repositories/file_import_repository.dart';

class ImportMovementsFromFileUseCase {
  const ImportMovementsFromFileUseCase(this._repository);

  final FileImportRepository _repository;

  Future<void> call({
    required String path,
    required String filename,
  }) {
    return _repository.uploadCsv(path: path, filename: filename);
  }
}
