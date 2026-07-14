abstract class FileImportRepository {
  Future<void> uploadCsv({
    required String path,
    required String filename,
  });
}
