import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({
    super.key,
    this.onProjectCreated,
    this.showProjectList = true,
    this.showProjectForm = true,
  });

  final VoidCallback? onProjectCreated;
  final bool showProjectList;
  final bool showProjectForm;

  void _openForm(BuildContext context, WidgetBuilder builder) {
    final navigator = Navigator.of(context);
    navigator.pop(); // Tutup drawer.
    navigator.pushReplacement(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Navigasi ke halaman utama portofolio
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop(); // Tutup drawer.
              if (navigator.canPop()) {
                navigator.popUntil((route) => route.isFirst);
              } else {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const MyHomePage()),
                );
              }
            },
          ),
          if (showProjectList)
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Lihat Proyek'),
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push<void>(
                  MaterialPageRoute(builder: (_) => const ProjectListScreen()),
                );
              },
            ),
          if (showProjectForm)
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Project'),
              onTap: () async {
                final pageContext = Scaffold.of(context).context;
                final navigator = Navigator.of(pageContext);
                navigator.pop();
                if (!await ensureLoggedIn(pageContext) ||
                    !pageContext.mounted) {
                  return;
                }
                final created = await navigator.push<bool>(
                  MaterialPageRoute(builder: (_) => const ProjectFormPage()),
                );
                if (created == true && pageContext.mounted) {
                  onProjectCreated?.call();
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _openForm(context, (_) => const EducationFormPage()),
          ),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () async {
              final pageContext = Scaffold.of(context).context;
              Navigator.of(pageContext).pop();
              if (isLoggedIn) {
                await logoutWithFeedback(pageContext);
              } else {
                await ensureLoggedIn(pageContext);
              }
            },
          ),
        ],
      ),
    );
  }
}
