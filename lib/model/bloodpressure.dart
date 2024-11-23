import 'dart:convert';

import 'package:healthlog/model/record.dart';

class BloodPressure extends HealthRecord<BP> {
  BloodPressure({
    super.id,
    required super.user,
    required super.type,
    required super.date,
    required super.content,
    required super.comments,
  });

  factory BloodPressure.fromJson(String json) {
    var map = jsonDecode(json);
    return BloodPressure.fromMap(map);
  }

  factory BloodPressure.fromMap(Map<String, dynamic> map) {
    return BloodPressure(
      id: map["id"],
      user: map["user"],
      type: map["type"],
      content: BP.fromMap(jsonDecode(map["content"])),
      date: map["date"],
      comments: map["comments"],
    );
  }
}

class BP {
  final int systolic;
  final int diastolic;
  final int heartrate;
  final String arm;

  BP({
    required this.systolic,
    required this.diastolic,
    required this.heartrate,
    required this.arm,
  });

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'heartrate': heartrate,
      'arm': arm
    };
  }

  factory BP.fromJson(String json) {
    var map = jsonDecode(json);
    return BP(
        systolic: map["systolic"],
        diastolic: map["diastolic"],
        heartrate: map["heartrate"],
        arm: map["arm"]);
  }

  BP.fromMap(Map<String, dynamic> res)
      : systolic = res['systolic'],
        diastolic = res['diastolic'],
        heartrate = res['heartrate'],
        arm = res['arm'];
}
