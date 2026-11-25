import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (project.projectImageUrl.isNotEmpty) ...[
              Image.network(
                project.projectImageUrl,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Center(child: Text('Gambar proyek gagal dimuat.')),
              ),
              const SizedBox(height: 16),
            ],
            Text('Deskripsi', style: textTheme.titleMedium),
            Text(project.description),
            const SizedBox(height: 16),
            Text('Teknologi', style: textTheme.titleMedium),
            Text(project.techStack),
            if (project.projectUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Tautan Proyek', style: textTheme.titleMedium),
              SelectableText(project.projectUrl),
            ],
          ],
        ),
      ),
    );
  }
}
