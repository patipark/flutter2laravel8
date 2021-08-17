import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter2laravel8/models/user.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? _user;

  @override
  void initState() {
    _login();
    super.initState();
  }

  void _login() async {
    try {
      String url = BASE_API_URL + '/login';
      print(url);
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      var body = json.encode({"email": "iamwad@gmail.com", "password": "1234"});
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      // print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var parsed = json.decode(response.body);
        // print(parsed);
        // var user = User.fromJson(parsed['user']);
        setState(() {
          _user = User.fromJson(parsed['user']);
        });
        inspect(_user);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loginData', response.body);
      } else {
        print('Could not post data. @ login.page._login()');
        throw Exception('ไม่สามารถโหลดข้อมูลจาก API ได้ (Error Code:' +
            response.statusCode.toString() +
            ')');
      }
    } catch (e) {
      print('error on login.page._login() => $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('LoginPage'),
    );
  }
}
