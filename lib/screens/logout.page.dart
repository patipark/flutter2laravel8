import 'package:flutter/material.dart';

class LoginOut extends StatefulWidget {
  LoginOut({Key? key}) : super(key: key);

  @override
  _LoginOutState createState() => _LoginOutState();
}

class _LoginOutState extends State<LoginOut> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Logout'),
    );
  }
}
