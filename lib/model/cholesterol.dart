import 'dart:convert';
import 'package:healthlog/model/record.dart';

class Cholesterol extends HealthRecord<CHLSTRL> {
  Cholesterol(
      {super.id,
      required super.user,
      required super.type,
      required super.date,
      required super.content,
      required super.comments});

  factory Cholesterol.fromJson(String json) {
    var map = jsonDecode(json);
    return Cholesterol.fromMap(map);
  }

  factory Cholesterol.fromMap(Map<String, dynamic> map) {
    return Cholesterol(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: CHLSTRL.fromJson(jsonDecode(map["content"])),
        date: map['date'],
        comments: map['comments']);
  }
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
