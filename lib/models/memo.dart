class Memo {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime reminderTime;
  final bool isCompleted;

  Memo({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.reminderTime,
    this.isCompleted = false,
  });

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reminderTime: DateTime.parse(json['reminderTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'reminderTime': reminderTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  Memo copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? reminderTime,
    bool? isCompleted,
  }) {
    return Memo(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
