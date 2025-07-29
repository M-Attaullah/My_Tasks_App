enum TaskPriority { low, medium, high }

class Task {
  final int? id;
  String title;
  String? description;
  DateTime dueDate;
  TaskPriority priority;
  bool isCompleted;
  String? category;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.category,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: TaskPriority.values[(map['priority'] as int?) ?? 1],
      isCompleted: (map['isCompleted'] as int?) == 1,
      category: map['category'] as String?,
    );
  }
}
