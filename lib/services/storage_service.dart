import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_item.dart';

class StorageService {
  static const String keyDarkMode = 'app_theme_dark_mode';
  static const String keyUsername = 'user_display_name';
  static const String keyNotes = 'notes_list';

  final SharedPreferences prefs;

  StorageService(this.prefs);

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Dark Mode Persistence
  bool getIsDarkMode() {
    return prefs.getBool(keyDarkMode) ?? false;
  }

  Future<bool> setDarkMode(bool isDark) async {
    return await prefs.setBool(keyDarkMode, isDark);
  }

  // Username String Persistence
  String getUsername() {
    final String? name = prefs.getString(keyUsername);
    if (name == null || name.trim().isEmpty) {
      return 'Guest User';
    }
    return name;
  }

  Future<bool> setUsername(String username) async {
    return await prefs.setString(keyUsername, username.trim());
  }

  // Notes List JSON Serialization & Persistence
  List<NoteItem> getNotes() {
    final String? jsonStr = prefs.getString(keyNotes);
    if (jsonStr == null || jsonStr.trim().isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded
          .map((item) => NoteItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveNotes(List<NoteItem> notes) async {
    final List<Map<String, dynamic>> rawList =
        notes.map((note) => note.toJson()).toList();
    final String jsonString = jsonEncode(rawList);
    return await prefs.setString(keyNotes, jsonString);
  }
}
