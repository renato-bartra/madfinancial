import '../../domain/repositories/file_import_repository.dart';
import '../datasources/file_import_remote_data_source.dart';

class FileImportRepositoryImpl implements FileImportRepository {
  const FileImportRepositoryImpl(this._remoteDataSource);

  final FileImportRemoteDataSource _remoteDataSource;

  @override
  Future<void> uploadCsv({
    required String path,
    required String filename,
  }) {
    return _remoteDataSource.uploadCsv(path: path, filename: filename);
  }
}
