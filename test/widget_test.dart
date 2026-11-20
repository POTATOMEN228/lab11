import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks/main.dart';
import 'package:tasks/models/note_item.dart';
import 'package:tasks/screens/notes_vault_screen.dart';
import 'package:tasks/services/storage_service.dart';

void main() {
  group('NoteItem Serialization Tests', () {
    test('toJson and fromJson convert model correctly', () {
      final note = NoteItem(
        id: '123',
        title: 'Buy Groceries',
        dateText: '2026-11-20 14:00',
        isCompleted: true,
      );

      final jsonMap = note.toJson();
      expect(jsonMap['id'], '123');
      expect(jsonMap['title'], 'Buy Groceries');
      expect(jsonMap['dateText'], '2026-11-20 14:00');
      expect(jsonMap['isCompleted'], true);

      final deserialized = NoteItem.fromJson(jsonMap);
      expect(deserialized.id, '123');
      expect(deserialized.title, 'Buy Groceries');
      expect(deserialized.dateText, '2026-11-20 14:00');
      expect(deserialized.isCompleted, true);
    });
  });

  group('StorageService Unit Tests', () {
    test('Default values fallback correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      expect(storage.getIsDarkMode(), false);
      expect(storage.getUsername(), 'Guest User');
      expect(storage.getNotes(), isEmpty);
    });

    test('Saving and loading user preferences & notes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await storage.setDarkMode(true);
      await storage.setUsername('John Doe');

      final notes = [
        NoteItem(
          id: '1',
          title: 'First Note',
          dateText: '2026-11-20 10:00',
          isCompleted: false,
        ),
      ];
      await storage.saveNotes(notes);

      expect(storage.getIsDarkMode(), true);
      expect(storage.getUsername(), 'John Doe');

      final loadedNotes = storage.getNotes();
      expect(loadedNotes.length, 1);
      expect(loadedNotes.first.title, 'First Note');
    });
  });

  group('Widget & Integration Tests', () {
    testWidgets('App renders with Guest User fallback by default', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(NotesVaultApp(
        storageService: storage,
        initialIsDarkMode: storage.getIsDarkMode(),
        initialUsername: storage.getUsername(),
        initialNotes: storage.getNotes(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Offline-First Vault'), findsOneWidget);
      expect(find.text('Guest User'), findsOneWidget);
      expect(find.text('No Notes Found'), findsOneWidget);
    });

    testWidgets('User Profile Persistence updates SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(NotesVaultApp(
        storageService: storage,
        initialIsDarkMode: false,
        initialUsername: 'Guest User',
        initialNotes: const [],
      ));
      await tester.pumpAndSettle();

      final usernameField = find.byKey(const Key('username_text_field'));
      await tester.enterText(usernameField, 'Alice');
      await tester.tap(find.byKey(const Key('save_username_button')));
      await tester.pumpAndSettle();

      final headerUsernameText = find.byKey(const Key('header_username_text'));
      expect(headerUsernameText, findsOneWidget);
      expect((tester.widget(headerUsernameText) as Text).data, 'Alice');
      expect(prefs.getString('user_display_name'), 'Alice');
    });

    testWidgets('Theme Toggle updates dark mode state and SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(NotesVaultApp(
        storageService: storage,
        initialIsDarkMode: false,
        initialUsername: 'Guest User',
        initialNotes: const [],
      ));
      await tester.pumpAndSettle();

      final switchFinder = find.byKey(const Key('dark_mode_switch'));
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(prefs.getBool('app_theme_dark_mode'), true);
    });

    testWidgets('Notes CRUD operations (Add, Toggle, Delete)', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = StorageService(prefs);

      await tester.pumpWidget(NotesVaultApp(
        storageService: storage,
        initialIsDarkMode: false,
        initialUsername: 'Guest User',
        initialNotes: const [],
      ));
      await tester.pumpAndSettle();

      // Add note
      final noteField = find.byKey(const Key('note_title_text_field'));
      await tester.enterText(noteField, 'Test Note 1');
      await tester.tap(find.byKey(const Key('add_note_button')));
      await tester.pumpAndSettle();

      expect(find.text('Test Note 1'), findsOneWidget);
      expect(prefs.getString('notes_list'), contains('Test Note 1'));

      // Dismiss snackbars so tap hits the checkbox directly
      ScaffoldMessenger.of(tester.element(find.byType(NotesVaultScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Toggle note completion
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(prefs.getString('notes_list'), contains('"isCompleted":true'));

      // Delete note
      final deleteBtn = find.byIcon(Icons.delete_outline).first;
      await tester.tap(deleteBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Test Note 1'), findsNothing);
      expect(prefs.getString('notes_list'), '[]');
    });
  });
}
