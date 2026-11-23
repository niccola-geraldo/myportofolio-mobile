import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

Future<void> openFromCard(WidgetTester tester) async {
  final card = find.text('Tambah Edukasi');
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

Future<void> selectDrawerItem(WidgetTester tester, String label) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> fillField(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

Future<void> saveForm(WidgetTester tester) async {
  final save = find.widgetWithText(FilledButton, 'Simpan');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Edukasi dapat dibuka dari kartu dan drawer', (tester) async {
    await tester.pumpWidget(const MyApp());
    final home = tester.element(find.byType(MyHomePage));

    await openFromCard(tester);
    expect(find.byType(EducationFormPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(MyHomePage)), same(home));

    await openFromCard(tester);
    await selectDrawerItem(tester, 'Home');
    expect(tester.element(find.byType(MyHomePage)), same(home));

    await selectDrawerItem(tester, 'Add Education');
    expect(find.byType(EducationFormPage), findsOneWidget);
    await selectDrawerItem(tester, 'Home');
    expect(find.byType(MyHomePage), findsOneWidget);

    await selectDrawerItem(tester, 'Add Project');
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Simpan memvalidasi dan merangkum seluruh isian edukasi', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await selectDrawerItem(tester, 'Add Education');

    await fillField(tester, 'Institusi', '   ');
    await fillField(tester, 'Jurusan', 'Ilmu Komputer');
    await fillField(tester, 'Deskripsi', 'Belajar pengembangan aplikasi.');
    await fillField(tester, 'Tahun Mulai', '2024');
    await fillField(tester, 'Tahun Selesai (opsional)', '2023');
    await fillField(tester, 'GPA (opsional)', '4.01');
    await saveForm(tester);

    expect(find.text('Institusi wajib diisi.'), findsOneWidget);
    expect(
      find.text('Tahun selesai harus sama dengan atau setelah tahun mulai.'),
      findsOneWidget,
    );
    expect(
      find.text('Masukkan GPA 0–4 dengan maksimal dua angka desimal.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);

    await fillField(tester, 'Institusi', '<b>Universitas Indonesia</b>');
    final degree = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(degree);
    await tester.tap(degree);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Magister (S2)').last);
    await tester.pumpAndSettle();
    await fillField(tester, 'Tahun Selesai (opsional)', '2024');
    await fillField(tester, 'GPA (opsional)', '3.75');
    await saveForm(tester);

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    for (final line in [
      'Institusi: Universitas Indonesia',
      'Jenjang: Magister (S2)',
      'Jurusan: Ilmu Komputer',
      'Deskripsi: Belajar pengembangan aplikasi.',
      'Tahun Mulai: 2024',
      'Tahun Selesai: 2024',
      'GPA: 3.75',
    ]) {
      expect(
        find.descendant(of: dialog, matching: find.text(line)),
        findsOneWidget,
      );
    }
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);

    await fillField(tester, 'Tahun Selesai (opsional)', '');
    await fillField(tester, 'GPA (opsional)', '');
    await saveForm(tester);
    expect(find.text('Tahun Selesai: Masih berlangsung'), findsOneWidget);
    expect(find.text('GPA: Belum diisi'), findsOneWidget);
  });

  testWidgets('Simpan tetap terjangkau saat papan ketik tampil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MyApp());
    await selectDrawerItem(tester, 'Add Education');

    await fillField(tester, 'GPA (opsional)', '3,75');
    expect(tester.testTextInput.isVisible, isTrue);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pumpAndSettle();

    final save = find.widgetWithText(FilledButton, 'Simpan');
    await tester.ensureVisible(save);
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
