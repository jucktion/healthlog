import 'dart:convert';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final int age;
  final double weight;
  final double height;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.age,
      required this.weight,
      required this.height});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }

  factory User.fromJson(String json) {
    var map = jsonDecode(json);
    return User(
        id: map["id"],
        firstName: map["firstName"],
        lastName: map["lastName"],
        age: map["age"],
        weight: map["weight"].toDouble(),
        height: map["height"].toDouble());
  }

  User.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        firstName = res["firstName"],
        lastName = res['lastName'],
        age = res['age'],
        weight = res['weight'].toDouble(),
        height = res['height'].toDouble();
}
