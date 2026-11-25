import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _techStack = TextEditingController();
  final _projectUrl = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _techStack.dispose();
    _projectUrl.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  String? _validateUrl(String? input) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        value.contains(RegExp(r'\s'))) {
      return 'Masukkan URL HTTP atau HTTPS yang valid.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = auth.token;
      if (token == null) return;
      final project = Project(
        title: _title.text.trim(),
        description: _description.text.trim(),
        techStack: _techStack.text.trim(),
        projectUrl: _projectUrl.text.trim(),
        projectImageUrl: _imageUrl.text.trim(),
      );
      final created = await context.read<ApiClient>().createProject(
        project,
        token: token,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text(created.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        try {
          await auth.logout();
        } on ApiException {
          // AuthState clears the local session even if revocation fails.
        }
        if (!mounted) return;
        _showMessage('Sesi berakhir. Silakan login kembali.');
        await ensureLoggedIn(context);
      } else {
        final message = switch (error.statusCode) {
          400 => 'Server menolak isian proyek. Periksa kembali formulir.',
          403 => 'Akun ini tidak memiliki izin menambah proyek.',
          _ => error.message,
        };
        _showMessage(message);
      }
    } on FormatException {
      if (mounted) _showMessage('Respons proyek dari server tidak valid.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Project Form')),
        drawer: _isSubmitting ? null : const LeftDrawer(showProjectForm: false),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field('Nama Proyek', _title, required: true),
                  _field(
                    'Deskripsi Proyek',
                    _description,
                    required: true,
                    lines: 4,
                  ),
                  _field(
                    'Teknologi yang Digunakan',
                    _techStack,
                    required: true,
                  ),
                  _field('Tautan Proyek', _projectUrl, isUrl: true),
                  _field(
                    'URL Gambar Proyek (opsional)',
                    _imageUrl,
                    isUrl: true,
                  ),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(_isSubmitting ? 'Menyimpan…' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool isUrl = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      enabled: !_isSubmitting,
      keyboardType: isUrl ? TextInputType.url : null,
      maxLines: lines,
      validator: (value) {
        if (required && (value ?? '').trim().isEmpty) {
          return '$label wajib diisi.';
        }
        return isUrl ? _validateUrl(value) : null;
      },
    ),
  );
}
