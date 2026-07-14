import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/movements_providers.dart';

class ImportFilePage extends ConsumerStatefulWidget {
  const ImportFilePage({super.key});

  @override
  ConsumerState<ImportFilePage> createState() => _ImportFilePageState();
}

class _ImportFilePageState extends ConsumerState<ImportFilePage> {
  String? _selectedPath;
  String? _selectedFilename;
  bool _isPicking = false;
  bool _isImporting = false;

  Future<void> _pickFile() async {
    if (_isPicking || _isImporting) return;
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        allowMultiple: false,
        withData: false,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.first;
      final path = file.path;
      if (path == null || path.isEmpty) {
        _showError('No se pudo acceder al archivo seleccionado.');
        return;
      }
      final extension = file.extension?.toLowerCase();
      if (extension != null && extension != 'csv') {
        _showError('Solo se permiten archivos CSV.');
        return;
      }
      setState(() {
        _selectedPath = path;
        _selectedFilename = file.name;
      });
    } catch (e) {
      if (mounted) _showError('No se pudo abrir el selector de archivos: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _import() async {
    final path = _selectedPath;
    final filename = _selectedFilename;
    if (path == null || filename == null || _isImporting) return;
    setState(() => _isImporting = true);
    try {
      await ref
          .read(importMovementsFromFileUseCaseProvider)
          .call(path: path, filename: filename);

      if (!mounted) return;
      await ref.read(movementLocalDaoProvider).clearMovements();
      if (!mounted) return;
      await ref
          .read(movementsControllerProvider.notifier)
          .loadCurrentMonth();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Archivo importado correctamente. Movimientos sincronizados.',
          ),
          duration: Duration(seconds: 20),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showError(
          e.toString().isEmpty
              ? 'No se pudo importar el archivo.'
              : e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 20),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final canImport =
        _selectedPath != null && _selectedFilename != null && !_isImporting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 6),
                    Text(
                      'Importación desde archivo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Por el momento, la aplicación solo admite la importación '
                      'de archivos en formato CSV con la estructura indicada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 20),
                    _CsvExampleTable(),
                    SizedBox(height: 22),
                    Text(
                      'Antes de importar un archivo, tenga en cuenta lo siguiente:',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    _Bullet(
                      text:
                          'Solo se crearán los movimientos contenidos en el archivo CSV. Los submovimientos y tags únicamente podrán crearse o editarse desde la aplicación.',
                    ),
                    _Bullet(
                      text:
                          'Utilice únicamente categorías, tipos y cuentas que ya existan en su base de datos. Los nombres deben coincidir exactamente, incluyendo mayúsculas, minúsculas y espacios. Si se encuentra algún dato que no coincida, la aplicación le indicará el error para que pueda corregirlo.',
                    ),
                    _Bullet(
                      text:
                          'El formato de la fecha de la columna Fecha es Año-Mes-Día',
                    ),
                    _Bullet(
                      text:
                          'El monto solo debe contener números, las decimales deben estar separados por un punto (.)',
                    ),
                    _Bullet(
                      text: 'El archivo CSV no debe superar los 10 MB de tamaño.',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: _AttachRow(
                filename: _selectedFilename,
                disabled: _isPicking || _isImporting,
                onPressed: _pickFile,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: canImport ? _import : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onSurface,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.4),
                    disabledForegroundColor: AppColors.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isImporting
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onSurface,
                          ),
                        )
                      : const Text(
                          'Importar movimientos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachRow extends StatelessWidget {
  const _AttachRow({
    required this.filename,
    required this.disabled,
    required this.onPressed,
  });

  final String? filename;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: disabled ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: AppColors.onSurface,
              disabledBackgroundColor:
                  AppColors.info.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Adjuntar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: filename == null
              ? const Text(
                  '',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                )
              : Text(
                  filename!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.onSurfaceVariant,
                  ),
                ),
        ),
      ],
    );
  }
}

class _CsvExampleTable extends StatelessWidget {
  const _CsvExampleTable();

  static const _headers = [
    'Tipo',
    'Categoria',
    'Cuenta',
    'Titulo',
    'Monto',
    'Descripcion',
    'Fecha',
  ];
  static const _row = [
    'Gasto',
    'Cena',
    'Sueldo',
    'Cena con amigos',
    '120.3',
    'Pollo a la braza',
    '2026-04-23',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: _headers
                .map(
                  (h) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Row(
            children: _row
                .map(
                  (c) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        c,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(
              Icons.circle,
              size: 5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
