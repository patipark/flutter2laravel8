// To parse this JSON data, do
//
//     final login = loginFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'user.dart';

Login loginFromJson(String str) => Login.fromJson(json.decode(str));

String loginToJson(Login data) => json.encode(data.toJson());

class Login {
    Login({
        @required this.user,
        @required this.token,
    });

    final User? user;
    final String? token;

    factory Login.fromJson(Map<String, dynamic> json) => Login(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        token: json["token"] == null ? null : json["token"],
    );

    Map<String, dynamic> toJson() => {
        "user": user == null ? null : user!.toJson(),
        "token": token == null ? null : token,
    };
}
