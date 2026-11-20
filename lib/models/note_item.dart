class NoteItem {
  final String id;
  final String title;
  final String dateText;
  final bool isCompleted;

  NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    this.isCompleted = false,
  });

  NoteItem copyWith({
    String? id,
    String? title,
    String? dateText,
    bool? isCompleted,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      dateText: dateText ?? this.dateText,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateText': dateText,
      'isCompleted': isCompleted,
    };
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dateText: json['dateText'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          dateText == other.dateText &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ dateText.hashCode ^ isCompleted.hashCode;
}
