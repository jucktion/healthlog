import 'dart:convert';
import 'package:healthlog/model/record.dart';

class Data extends HealthRecord {
  Data(
      {super.id,
      required super.user,
      required super.type,
      required super.date,
      required super.content,
      required super.comments});

  factory Data.fromJson(String json) {
    var map = jsonDecode(json);
    return Data.fromMap(map);
  }

  factory Data.fromMap(Map<String, dynamic> res) {
    return Data(
        id: res["id"],
        user: res["user"],
        type: res["type"],
        content: res["content"],
        date: res['date'],
        comments: res['comments']);
  }
}
