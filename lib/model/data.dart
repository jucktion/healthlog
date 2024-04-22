import 'dart:convert';

class Data {
  late final int id;
  final String type;
  final int user;
  final String content;
  final String date;
  final String comments;
  Data(
      {required this.id,
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
      'content': content,
      'date': date,
      'comments': comments
    };
  }

  factory Data.fromJson(String json) {
    var map = jsonDecode(json);
    return Data(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: map["content"],
        date: map["date"],
        comments: map["comments"]);
  }

  Data.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        user = res["user"],
        type = res["type"],
        content = res["content"],
        date = res['date'],
        comments = res['comments'];
}
