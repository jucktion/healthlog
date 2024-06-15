import 'dart:convert';

class BloodPressure {
  final int? id;
  final String type;
  final int user;
  final BP content;
  final String date;
  final String comments;
  BloodPressure(
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

  factory BloodPressure.fromJson(String json) {
    var map = jsonDecode(json);
    return BloodPressure(
        id: map["id"],
        user: map["user"],
        type: map["type"],
        content: map["content"],
        date: map["date"],
        comments: map["comments"]);
  }

  BloodPressure.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        user = res["user"],
        type = res["type"],
        content = BP.fromJson(res["content"]),
        date = res['date'],
        comments = res['comments'];
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
