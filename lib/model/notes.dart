import 'dart:convert';

class Notes {
  final int? id;
  final String type;
  final int user;
  final Note content;
  final String date;
  final String comments;
  Notes(
      {this.id,
      required this.user,
      required this.type,
      required this.date,
      required this.content,
      required this.comments});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'type': type,
      'content': jsonEncode(content.toMap()),
      'date': date,
      'comments': comments
    };
  }

  factory Notes.fromJson(String json) {
    var map = jsonDecode(json);
    return Notes(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: map["content"],
        date: map["date"],
        comments: map["comments"]);
  }

  Notes.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        user = res["user"],
        type = res["type"],
        content = Note.fromJson(res["content"]),
        date = res['date'],
        comments = res['comments'];
}

class Note {
  final String title;
  final String note;
  final String type;

  Note({required this.title, required this.note, required this.type});

  Map<String, dynamic> toMap() {
    return {'title': title, 'note': note, 'type': type};
  }

  factory Note.fromJson(String json) {
    var map = jsonDecode(json);
    return Note(title: map["title"], note: map["note"], type: map["type"]);
  }

  Note.fromMap(Map<String, dynamic> res)
      : title = res['title'],
        note = res['note'],
        type = res['type'];
}
