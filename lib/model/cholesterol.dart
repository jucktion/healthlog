import 'dart:convert';

class Cholesterol {
  late final int id;
  final String type;
  final int user;
  final CHLSTRL content;
  final String date;
  final String comments;
  Cholesterol(
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

  factory Cholesterol.fromJson(String json) {
    var map = jsonDecode(json);
    return Cholesterol(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: map["content"],
        date: map["date"],
        comments: map["comments"]);
  }

  Cholesterol.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        user = res["user"],
        type = res["type"],
        content = CHLSTRL.fromJson(res["content"]),
        date = res['date'],
        comments = res['comments'];
}

class CHLSTRL {
  final double total;
  final double tag;
  final double hdl;
  final double ldl;
  final String unit;

  CHLSTRL(
      {required this.total,
      required this.tag,
      required this.hdl,
      required this.ldl,
      required this.unit});

  Map<String, dynamic> toMap() {
    return {'total': total, 'tag': tag, 'hdl': hdl, 'ldl': ldl, 'unit': unit};
  }

  factory CHLSTRL.fromJson(String json) {
    var map = jsonDecode(json);
    return CHLSTRL(
        total: map["total"],
        tag: map["tag"],
        hdl: map["hdl"],
        ldl: map["ldl"],
        unit: map["unit"]);
  }

  CHLSTRL.fromMap(Map<String, dynamic> res)
      : total = res['total'],
        tag = res['tag'],
        hdl = res['hdl'],
        ldl = res['ldl'],
        unit = res['unit'];
}
