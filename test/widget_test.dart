import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

const _project = {
  'id': '4985eae6-a23d-4aa3-8596-fdcc9dfcfa97',
  'title': 'Portofolio',
  'description': 'Aplikasi pribadi',
  'tech_stack': 'Flutter',
  'project_url': 'https://example.com/',
};

Future<void> _startApp(
  WidgetTester tester,
  Future<http.Response> Function(http.Request) onRequest,
) async {
  final api = ApiClient(client: MockClient(onRequest));
  addTearDown(api.close);
  await tester.pumpWidget(MyApp(apiClient: api));
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  await _fill(tester, 'Username', 'owner');
  await _fill(tester, 'Password', 'secret');
  await _tap(tester, find.widgetWithText(FilledButton, 'Login'));
}

void main() {
  testWidgets('Menu menampilkan identitas dan keempat tombol aksi', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('2506619070'), findsOneWidget);
    expect(find.text('Niccola Geraldo Winaryo Durand'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.byType(ItemCard), findsNWidgets(4));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Proyek publik dapat dibuka tanpa login', (tester) async {
    var requests = 0;
    await _startApp(tester, (request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/projects/');
      expect(request.headers, isNot(contains('authorization')));
      requests++;
      return http.Response(jsonEncode([_project]), 200);
    });

    await _tap(tester, find.text('Lihat Proyek'));
    expect(find.text('Daftar Proyek'), findsOneWidget);
    await _tap(tester, find.text('Portofolio'));
    expect(find.text('Aplikasi pribadi'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('https://example.com/'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(requests, 1);
  });

  testWidgets('Daftar dapat dicoba ulang dan disegarkan saat kosong', (
    tester,
  ) async {
    var requests = 0;
    await _startApp(tester, (_) async {
      requests++;
      return switch (requests) {
        1 => http.Response('', 503),
        2 => http.Response('[]', 200),
        _ => http.Response(jsonEncode([_project]), 200),
      };
    });

    await _tap(tester, find.text('Lihat Proyek'));
    await _tap(tester, find.text('Coba lagi'));
    expect(find.text('Belum ada proyek.'), findsOneWidget);
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 320));
    await tester.pumpAndSettle();
    expect(find.text('Portofolio'), findsOneWidget);
    expect(requests, 3);
  });

  testWidgets('Add Project meminta login, menyimpan, dan memuat ulang daftar', (
    tester,
  ) async {
    http.Request? projectRequest;
    await _startApp(tester, (request) async {
      switch (request.url.path) {
        case '/api/v1/auth/token/':
          expect(request.method, 'POST');
          final credentials = jsonDecode(request.body) as Map<String, dynamic>;
          expect(credentials['username'], 'owner');
          if (credentials['password'] == 'wrong-password') {
            return http.Response('{}', 400);
          }
          expect(credentials['password'], 'secret');
          return http.Response('{"token":"example-token"}', 200);
        case '/api/v1/projects/':
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode(projectRequest == null ? [] : [_project]),
              200,
            );
          }
          projectRequest = request;
          return http.Response(jsonEncode(_project), 201);
        default:
          fail('Unexpected request: ${request.url}');
      }
    });

    await _tap(tester, find.text('Lihat Proyek'));
    await _tap(tester, find.byIcon(Icons.menu));
    await _tap(tester, find.text('Add Project'));
    expect(find.text('Add Project Form'), findsNothing);
    await _fill(tester, 'Username', 'owner');
    await _fill(tester, 'Password', 'wrong-password');
    await _tap(tester, find.widgetWithText(FilledButton, 'Login'));
    expect(
      find.text('Username atau password salah (HTTP 400).'),
      findsOneWidget,
    );
    await _login(tester);
    expect(find.text('Add Project Form'), findsOneWidget);

    final save = find.widgetWithText(FilledButton, 'Save');
    await _fill(tester, 'Tautan Proyek', 'example.com');
    await _tap(tester, save);
    expect(find.text('Nama Proyek wajib diisi.'), findsOneWidget);
    expect(
      find.text('Masukkan URL HTTP atau HTTPS yang valid.'),
      findsOneWidget,
    );
    expect(projectRequest, isNull);

    await _fill(tester, 'Nama Proyek', 'Portofolio');
    await _fill(tester, 'Deskripsi Proyek', 'Aplikasi pribadi');
    await _fill(tester, 'Teknologi yang Digunakan', 'Flutter');
    await _fill(tester, 'Tautan Proyek', 'https://example.com/');
    await _tap(tester, save);

    expect(projectRequest!.method, 'POST');
    expect(projectRequest!.headers['authorization'], 'Token example-token');
    expect(jsonDecode(projectRequest!.body), {
      'title': 'Portofolio',
      'description': 'Aplikasi pribadi',
      'tech_stack': 'Flutter',
      'project_url': 'https://example.com/',
      'project_image_url': '',
    });
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    await _tap(tester, find.text('OK'));
    expect(find.text('Daftar Proyek'), findsOneWidget);
    expect(find.text('Portofolio'), findsOneWidget);
  });

  testWidgets('Sesi kedaluwarsa meminta login ulang dan menyimpan isian', (
    tester,
  ) async {
    var writes = 0;
    await _startApp(tester, (request) async {
      switch (request.url.path) {
        case '/api/v1/auth/token/':
          return http.Response('{"token":"example-token"}', 200);
        case '/api/v1/auth/logout/':
          return http.Response('', 401);
        case '/api/v1/projects/':
          writes++;
          return writes == 1
              ? http.Response('', 401)
              : http.Response(jsonEncode(_project), 201);
        default:
          fail('Unexpected request: ${request.url}');
      }
    });

    await _tap(tester, find.text('Tambah Proyek'));
    await _login(tester);
    await _fill(tester, 'Nama Proyek', 'Portofolio');
    await _fill(tester, 'Deskripsi Proyek', 'Aplikasi pribadi');
    await _fill(tester, 'Teknologi yang Digunakan', 'Flutter');
    final save = find.widgetWithText(FilledButton, 'Save');
    await _tap(tester, save);
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    await _login(tester);
    expect(find.text('Portofolio'), findsOneWidget);
    expect(writes, 1);
    await _tap(tester, save);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(writes, 2);
  });

  testWidgets('Logout membersihkan sesi lokal saat server menolak', (
    tester,
  ) async {
    await _startApp(tester, (request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        return http.Response('{"token":"example-token"}', 200);
      }
      expect(request.url.path, '/api/v1/auth/logout/');
      expect(request.method, 'POST');
      expect(request.headers['authorization'], 'Token example-token');
      return http.Response('', 503);
    });

    await _tap(tester, find.text('Login'));
    await _login(tester);
    await _tap(tester, find.text('Logout'));
    expect(find.text('Login'), findsOneWidget);
    expect(find.textContaining('Token server gagal dicabut'), findsOneWidget);
  });

  testWidgets('Menu dapat ditampilkan pada layar ponsel yang pendek', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await _tap(tester, find.text('Tambah Edukasi'));
    expect(tester.takeException(), isNull);
  });
}
