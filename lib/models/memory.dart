class Memory {
  final int? id;
  final String title;
  final String details;
  final DateTime date;
  final int? categoryId;      // new: reference to categories table
  final DateTime? reminder;
  final String? photoPath;    // new: path to saved image

  Memory({
    this.id,
    required this.title,
    required this.details,
    required this.date,
    this.categoryId,
    this.reminder,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'reminder': reminder?.toIso8601String(),
      'photoPath': photoPath,
    };
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'],
      title: map['title'],
      details: map['details'],
      date: DateTime.parse(map['date']),
      categoryId: map['categoryId'],
      reminder: map['reminder'] != null ? DateTime.parse(map['reminder']) : null,
      photoPath: map['photoPath'],
    );
  }
}