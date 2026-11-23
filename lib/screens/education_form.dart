import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  static const _degrees = ['SD', 'SMP', 'SMA', 'Sarjana (S1)', 'Magister (S2)'];
  static const _firstYear = 1900;
  static const _lastYear = 2100;

  static final _htmlTags = RegExp(
    r"""<!--[\s\S]*?-->|</?[a-zA-Z][\w:-]*(?:[^<>"']|"[^"]*"|'[^']*')*>""",
  );
  static final _wholeNumber = RegExp(r'^[0-9]+$');
  static final _decimal = RegExp(
    r'^(?:[0-9]+(?:[.,][0-9]{1,2})?|[.,][0-9]{1,2})$',
  );

  final _formKey = GlobalKey<FormState>();
  final _institution = TextEditingController();
  final _major = TextEditingController();
  final _description = TextEditingController();
  final _startYear = TextEditingController();
  final _endYear = TextEditingController();
  final _gpa = TextEditingController();
  String _degree = 'Sarjana (S1)';

  @override
  void dispose() {
    _institution.dispose();
    _major.dispose();
    _description.dispose();
    _startYear.dispose();
    _endYear.dispose();
    _gpa.dispose();
    super.dispose();
  }

  String _cleanText(String? value) =>
      (value ?? '').replaceAll(_htmlTags, '').trim();

  String? _validateText(String? value, String label, {int? maxLength}) {
    final text = _cleanText(value);
    if (text.isEmpty) return '$label wajib diisi.';
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  int? _parseYear(String value) =>
      _wholeNumber.hasMatch(value) ? int.tryParse(value) : null;

  String? _validateYear(String? value, {bool optional = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return optional ? null : 'Tahun mulai wajib diisi.';

    final year = _parseYear(text);
    if (year == null || year < _firstYear || year > _lastYear) {
      return 'Masukkan tahun antara $_firstYear dan $_lastYear.';
    }
    if (optional) {
      final start = _parseYear(_startYear.text.trim());
      if (start != null && year < start) {
        return 'Tahun selesai harus sama dengan atau setelah tahun mulai.';
      }
    }
    return null;
  }

  String? _validateGpa(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final number = double.tryParse(text.replaceAll(',', '.'));
    if (number == null ||
        !_decimal.hasMatch(text) ||
        number < 0 ||
        number > 4) {
      return 'Masukkan GPA 0–4 dengan maksimal dua angka desimal.';
    }
    return null;
  }

  void _showSummary() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final endYear = _endYear.text.trim();
    final gpa = _gpa.text.trim();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Ringkasan Edukasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Institusi: ${_cleanText(_institution.text)}'),
            Text('Jenjang: $_degree'),
            Text('Jurusan: ${_cleanText(_major.text)}'),
            Text('Deskripsi: ${_cleanText(_description.text)}'),
            Text('Tahun Mulai: ${_startYear.text.trim()}'),
            Text(
              'Tahun Selesai: ${endYear.isEmpty ? 'Masih berlangsung' : endYear}',
            ),
            Text('GPA: ${gpa.isEmpty ? 'Belum diisi' : gpa}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      errorMaxLines: 3,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Edukasi'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _institution,
                      decoration: _decoration('Institusi'),
                      validator: (value) =>
                          _validateText(value, 'Institusi', maxLength: 255),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _degree,
                      isExpanded: true,
                      decoration: _decoration('Jenjang'),
                      items: [
                        for (final degree in _degrees)
                          DropdownMenuItem(value: degree, child: Text(degree)),
                      ],
                      onChanged: (value) {
                        if (value != null) _degree = value;
                      },
                      validator: (value) =>
                          _degrees.contains(value) ? null : 'Pilih jenjang.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _major,
                      decoration: _decoration('Jurusan'),
                      validator: (value) =>
                          _validateText(value, 'Jurusan', maxLength: 255),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      decoration: _decoration('Deskripsi'),
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 5,
                      validator: (value) => _validateText(value, 'Deskripsi'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startYear,
                      decoration: _decoration('Tahun Mulai'),
                      keyboardType: TextInputType.number,
                      validator: _validateYear,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _endYear,
                      decoration: _decoration(
                        'Tahun Selesai (opsional)',
                        helperText: 'Kosongkan jika masih berlangsung.',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validateYear(value, optional: true),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gpa,
                      decoration: _decoration('GPA (opsional)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _validateGpa,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _showSummary,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
