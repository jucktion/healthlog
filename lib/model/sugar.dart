import 'dart:convert';

import 'package:healthlog/model/record.dart';

class Sugar extends HealthRecord<SG> {
  Sugar({
    super.id,
    required super.user,
    required super.type,
    required super.date,
    required super.content,
    required super.comments,
  });

  factory Sugar.fromJson(String json) {
    var map = jsonDecode(json);
    return Sugar.fromMap(map);
  }

  factory Sugar.fromMap(Map<String, dynamic> map) {
    return Sugar(
      id: map["id"],
      user: map["user"],
      type: map["type"],
      content: SG.fromMap(jsonDecode(map["content"])),
      date: map["date"],
      comments: map["comments"],
    );
  }
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
