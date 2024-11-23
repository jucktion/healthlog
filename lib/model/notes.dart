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
    return Notes.fromMap(jsonDecode(json));
  }

  factory Notes.fromMap(Map<String, dynamic> map) {
    return Notes(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: Note.fromJson(map["content"]),
        date: map['date'],
        comments: map['comments']);
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
    return Note.fromMap(jsonDecode(json));
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
        title: map['title'], note: map['note'], notetype: map['notetype']);
  }
}
