import 'dart:convert';

class Sugar {
  final int id;
  final String type;
  final int user;
  final SG content;
  final String date;
  final String comments;
  Sugar(
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
      'content': jsonEncode(content.toMap()),
      'date': date,
      'comments': comments
    };
  }

  factory Sugar.fromJson(String json) {
    var map = jsonDecode(json);
    return Sugar(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: map["content"],
        date: map["date"],
        comments: map["comments"]);
  }

  Sugar.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        user = res["user"],
        type = res["type"],
        content = SG.fromJson(res["content"]),
        date = res['date'],
        comments = res['comments'];
}

class SG {
  final double reading;
  final String beforeAfter;
  final String unit;

  SG({required this.reading, required this.beforeAfter, required this.unit});

  Map<String, dynamic> toMap() {
    return {
      'reading': reading,
      'beforeAfter': beforeAfter,
      'unit': unit,
    };
  }

  factory SG.fromJson(String json) {
    var map = jsonDecode(json);
    return SG(
        reading: map["reading"],
        beforeAfter: map["beforeAfter"],
        unit: map["unit"]);
  }

  SG.fromMap(Map<String, dynamic> res)
      : reading = res['reading'],
        beforeAfter = res['beforeAfter'],
        unit = res['unit'];
}
