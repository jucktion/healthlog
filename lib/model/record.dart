import 'dart:convert';

class HealthRecord<T> {
  final int? id;
  final String type;
  final int user;
  final T content;
  final String date;
  final String comments;

  HealthRecord({
    this.id,
    required this.user,
    required this.type,
    required this.date,
    required this.content,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'type': type,
      'content': jsonEncode((content as dynamic).toMap()),
      'date': date,
      'comments': comments,
    };
  }
}
