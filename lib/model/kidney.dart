import 'dart:convert';
import 'package:healthlog/model/record.dart';

class RenalTest extends HealthRecord<RFT> {
  RenalTest({
    super.id,
    required super.user,
    required super.type,
    required super.date,
    required super.content,
    required super.comments,
  });

  factory RenalTest.fromJson(String json) {
    return RenalTest.fromMap(jsonDecode(json));
  }

  factory RenalTest.fromMap(Map<String, dynamic> map) {
    return RenalTest(
      id: map["id"],
      user: map["user"],
      type: map["type"],
      content: RFT.fromMap(jsonDecode(map["content"])),
      date: map["date"],
      comments: map["comments"],
    );
  }
}

class RFT {
  final double bun;
  final double urea;
  final double creatinine;
  final double sodium;
  final double potassium;

  RFT(
      {required this.bun,
      required this.urea,
      required this.creatinine,
      required this.sodium,
      required this.potassium});

  Map<String, dynamic> toMap() {
    return {
      'bun': bun,
      'urea': urea,
      'creatinine': creatinine,
      'sodium': sodium,
      'potassium': potassium
    };
  }

  factory RFT.fromMap(Map<String, dynamic> map) {
    return RFT(
        bun: map['bun'],
        urea: map['urea'],
        creatinine: map['creatinine'],
        sodium: map['sodium'],
        potassium: map['potassium']);
  }
}
