import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          switch (item.name) {
            case 'Lihat Proyek':
              Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const ProjectListScreen()),
              );
            case 'Tambah Proyek':
              if (!await ensureLoggedIn(context) || !context.mounted) return;
              Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const ProjectFormPage()),
              );
            case 'Login':
              await ensureLoggedIn(context);
            case 'Logout':
              await logoutWithFeedback(context);
            case 'Tambah Edukasi':
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Kamu telah menekan tombol Tambah Edukasi!'),
                  ),
                );
              Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const EducationFormPage()),
              );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
