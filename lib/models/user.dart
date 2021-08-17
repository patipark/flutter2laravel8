// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    @required this.id,
    @required this.fullname,
    @required this.username,
    @required this.email,
    @required this.emailVerifiedAt,
    @required this.tel,
    @required this.role,
    @required this.createdAt,
    @required this.updatedAt,
  });

  final int? id;
  final String? fullname;
  final String? username;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String? tel;
  final int? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        fullname: json["fullname"] == null ? null : json["fullname"],
        username: json["username"] == null ? null : json["username"],
        email: json["email"] == null ? null : json["email"],
        emailVerifiedAt: json["email_verified_at"] == null
            ? null
            : DateTime.parse(json["email_verified_at"]),
        tel: json["tel"] == null ? null : json["tel"],
        role: json["role"] == null ? null : json["role"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "fullname": fullname == null ? null : fullname,
        "username": username == null ? null : username,
        "email": email == null ? null : email,
        "email_verified_at":
            emailVerifiedAt == null ? null : emailVerifiedAt!.toIso8601String(),
        "tel": tel == null ? null : tel,
        "role": role == null ? null : role,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
      };
}
