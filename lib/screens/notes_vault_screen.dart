import 'package:flutter/material.dart';
import '../models/note_item.dart';

class NotesVaultScreen extends StatefulWidget {
  final bool isDarkMode;
  final String username;
  final List<NoteItem> notes;
  final ValueChanged<bool> onToggleDarkMode;
  final ValueChanged<String> onUpdateUsername;
  final ValueChanged<String> onAddNote;
  final ValueChanged<String> onToggleNote;
  final ValueChanged<String> onDeleteNote;

  const NotesVaultScreen({
    super.key,
    required this.isDarkMode,
    required this.username,
    required this.notes,
    required this.onToggleDarkMode,
    required this.onUpdateUsername,
    required this.onAddNote,
    required this.onToggleNote,
    required this.onDeleteNote,
  });

  @override
  State<NotesVaultScreen> createState() => _NotesVaultScreenState();
}

class _NotesVaultScreenState extends State<NotesVaultScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _noteTitleController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.username == 'Guest User' ? '' : widget.username,
    );
    _noteTitleController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant NotesVaultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      if (_usernameController.text != widget.username &&
          !(widget.username == 'Guest User' && _usernameController.text.isEmpty)) {
        _usernameController.text =
            widget.username == 'Guest User' ? '' : widget.username;
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _noteTitleController.dispose();
    super.dispose();
  }

  void _handleSaveUsername() {
    final newName = _usernameController.text.trim();
    widget.onUpdateUsername(newName);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepPurple,
        content: Text(
          newName.isEmpty
              ? 'Saved display name as Guest User'
              : 'Username saved: "$newName"',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAddNote() {
    final title = _noteTitleController.text.trim();
    if (title.isEmpty) return;
    widget.onAddNote(title);
    _noteTitleController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text(
          'Note added and saved to storage!',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline-First Vault',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.deepOrange,
              ),
              const SizedBox(width: 4),
              Switch(
                key: const Key('dark_mode_switch'),
                value: widget.isDarkMode,
                activeTrackColor: Colors.deepPurple.shade300,
                onChanged: widget.onToggleDarkMode,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Greeting Banner (Purple & Orange Theme)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isDarkMode
                      ? [
                          Colors.purple.shade900,
                          Colors.deepPurple.shade800,
                        ]
                      : [
                          Colors.deepPurple.shade700,
                          Colors.purple.shade600,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF5722),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.username,
                            key: const Key('header_username_text'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Profile Persistence Section (Purple Accent)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.deepPurple.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'User Profile',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('username_text_field'),
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              hintText: 'Enter your username',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _handleSaveUsername(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          key: const Key('save_username_button'),
                          onPressed: _handleSaveUsername,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Create Note Section (Orange Accent)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.deepOrange.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Add Note',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('note_title_text_field'),
                            controller: _noteTitleController,
                            decoration: const InputDecoration(
                              labelText: 'Note Title',
                              hintText: 'What needs to be done?',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _handleAddNote(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          key: const Key('add_note_button'),
                          onPressed: _handleAddNote,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notes Vault',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Chip(
                  label: Text(
                    '${widget.notes.length} item${widget.notes.length == 1 ? "" : "s"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes List or Empty State
            if (widget.notes.isEmpty)
              Card(
                elevation: 0,
                color: Colors.purple.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.deepPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.note_alt_outlined,
                        size: 48,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Notes Found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a note above to persist it to local storage!',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.notes.length,
                itemBuilder: (context, index) {
                  final note = widget.notes[index];
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) => widget.onDeleteNote(note.id),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: note.isCompleted
                              ? Colors.grey.shade300
                              : Colors.deepPurple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          key: Key('note_checkbox_${note.id}'),
                          value: note.isCompleted,
                          activeColor: Colors.deepOrange,
                          onChanged: (_) => widget.onToggleNote(note.id),
                        ),
                        title: Text(
                          note.title,
                          key: Key('note_title_${note.id}'),
                          style: TextStyle(
                            decoration: note.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            fontWeight: note.isCompleted
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          note.dateText,
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          key: Key('delete_note_button_${note.id}'),
                          icon: const Icon(Icons.delete_outline, color: Colors.deepOrange),
                          onPressed: () => widget.onDeleteNote(note.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
