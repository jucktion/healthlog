import 'dart:convert';
import 'package:healthlog/model/record.dart';

class RenalFunction extends HealthRecord<RFT> {
  RenalFunction({
    super.id,
    required super.user,
    required super.type,
    required super.date,
    required super.content,
    required super.comments,
  });

  factory RenalFunction.fromJson(String json) {
    return RenalFunction.fromMap(jsonDecode(json));
  }

  factory RenalFunction.fromMap(Map<String, dynamic> map) {
    return RenalFunction(
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
  final String unit;
  final double bun;
  final double urea;
  final double creatinine;
  final RFTel elements;

  RFT(
      {required this.unit,
      required this.bun,
      required this.urea,
      required this.creatinine,
      required this.elements});

  Map<String, dynamic> toMap() {
    return {
      'unit': unit,
      'bun': bun,
      'urea': urea,
      'creatinine': creatinine,
      'elements': jsonEncode((elements as dynamic).toMap())
    };
  }

  factory RFT.fromMap(Map<String, dynamic> map) {
    return RFT(
      unit: map['unit'],
      bun: map['bun'],
      urea: map['urea'],
      creatinine: map['creatinine'],
      elements: RFTel.fromMap(jsonDecode(map["elements"])),
    );
  }
}

class RFTel {
  final String unit;
  final double sodium;
  final double potassium;

  RFTel({required this.unit, required this.sodium, required this.potassium});

  Map<String, dynamic> toMap() {
    return {'unit': unit, 'sodium': sodium, 'potassium': potassium};
  }

  @override
  String toString() {
    return 'Element(unit: $unit, reading: $sodium , $potassium)';
  }

  factory RFTel.fromMap(Map<String, dynamic> map) {
    return RFTel(
        unit: map['unit'], sodium: map['sodium'], potassium: map['potassium']);
  }
}
