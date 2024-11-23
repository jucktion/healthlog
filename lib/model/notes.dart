import 'dart:convert';
import 'package:healthlog/model/record.dart';

class Notes extends HealthRecord<Note> {
  Notes(
      {super.id,
      required super.user,
      required super.type,
      required super.date,
      required super.content,
      required super.comments});

  factory Notes.fromJson(String json) {
    var map = jsonDecode(json);
    return Notes.fromMap(map);
  }

  factory Notes.fromMap(Map<String, dynamic> res) {
    return Notes(
        id: res["id"],
        user: res["user"],
        type: res["type"],
        content: Note.fromJson(jsonDecode(res["content"])),
        date: res['date'],
        comments: res['comments']);
  }
}

class Note {
  final String title;
  final String note;
  final String notetype;

  Note({required this.title, required this.note, required this.notetype});

  Map<String, dynamic> toMap() {
    return {'title': title, 'note': note, 'notetype': notetype};
  }

  factory Note.fromJson(String json) {
    var map = jsonDecode(json);
    return Note(
        title: map["title"], note: map["note"], notetype: map["notetype"]);
  }

  Note.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        note = map['note'],
        notetype = map['type'];
}
