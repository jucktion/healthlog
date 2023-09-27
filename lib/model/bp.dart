import 'dart:convert';

class BP {
  late final int id;
  final int user;
  final int systolic;
  final int diastolic;
  final int heartrate;
  final String arm;
  final String date;

  BP(
      {required this.id,
      required this.user,
      required this.systolic,
      required this.diastolic,
      required this.heartrate,
      required this.arm,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user': user,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartrate': heartrate,
      'arm': arm,
      'date': date
    };
  }

  factory BP.fromJson(String json) {
    var map = jsonDecode(json);
    return BP(
        id: map["id"],
        user: map["user"],
        systolic: map["systolic"],
        diastolic: map["diastolic"],
        heartrate: map["heartrate"],
        arm: map["arm"],
        date: map["date"]);
  }

  BP.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        user = res["user"],
        systolic = res['systolic'],
        diastolic = res['diastolic'],
        heartrate = res['heartrate'],
        arm = res['arm'],
        date = res['date'];
}
