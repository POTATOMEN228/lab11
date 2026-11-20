import 'package:flutter/material.dart';
import 'models/note_item.dart';
import 'screens/notes_vault_screen.dart';
import 'services/storage_service.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load SharedPreferences before runApp() to eliminate theme flickering
  final storageService = await StorageService.getInstance();
  final bool initialDarkMode = storageService.getIsDarkMode();
  final String initialUsername = storageService.getUsername();
  final List<NoteItem> initialNotes = storageService.getNotes();

  runApp(
    NotesVaultApp(
      storageService: storageService,
      initialIsDarkMode: initialDarkMode,
      initialUsername: initialUsername,
      initialNotes: initialNotes,
    ),
  );
}

class NotesVaultApp extends StatefulWidget {
  final StorageService? storageService;
  final bool initialIsDarkMode;
  final String initialUsername;
  final List<NoteItem>? initialNotes;

  const NotesVaultApp({
    super.key,
    this.storageService,
    this.initialIsDarkMode = false,
    this.initialUsername = 'Guest User',
    this.initialNotes,
  });

  @override
  State<NotesVaultApp> createState() => _NotesVaultAppState();
}

class _NotesVaultAppState extends State<NotesVaultApp> {
  StorageService? _storageService;
  late bool _isDarkMode;
  late String _username;
  late List<NoteItem> _notes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialIsDarkMode;
    _username = widget.initialUsername;
    _notes = List<NoteItem>.from(widget.initialNotes ?? []);

    if (widget.storageService != null) {
      _storageService = widget.storageService!;
      _isLoading = false;
    } else {
      _loadStorage();
    }
  }

  Future<void> _loadStorage() async {
    final service = await StorageService.getInstance();
    if (!mounted) return;
    setState(() {
      _storageService = service;
      _isDarkMode = service.getIsDarkMode();
      _username = service.getUsername();
      _notes = List<NoteItem>.from(service.getNotes());
      _isLoading = false;
    });
  }

  void _handleToggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    await _storageService?.setDarkMode(value);
  }

  void _handleUpdateUsername(String newName) async {
    final String savedName = newName.trim().isEmpty ? 'Guest User' : newName.trim();
    setState(() {
      _username = savedName;
    });
    await _storageService?.setUsername(savedName);
  }

  void _handleAddNote(String title) async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final dateStr = '$year-$month-$day $hour:$minute';

    final newNote = NoteItem(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      dateText: dateStr,
      isCompleted: false,
    );

    setState(() {
      _notes.insert(0, newNote);
    });
    await _storageService?.saveNotes(_notes);
  }

  void _handleToggleNote(String id) async {
    setState(() {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          isCompleted: !_notes[index].isCompleted,
        );
      }
    });
    await _storageService?.saveNotes(_notes);
  }

  void _handleDeleteNote(String id) async {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
    await _storageService?.saveNotes(_notes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline-First Notes & Settings Vault',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.deepOrange,
          tertiary: Colors.orange,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.deepPurple,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: const Color(0xFFB388FF),
          secondary: const Color(0xFFFFAB40),
          tertiary: const Color(0xFFFF9800),
          brightness: Brightness.dark,
        ),
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : NotesVaultScreen(
              isDarkMode: _isDarkMode,
              username: _username,
              notes: _notes,
              onToggleDarkMode: _handleToggleDarkMode,
              onUpdateUsername: _handleUpdateUsername,
              onAddNote: _handleAddNote,
              onToggleNote: _handleToggleNote,
              onDeleteNote: _handleDeleteNote,
            ),
    );
  }
}
