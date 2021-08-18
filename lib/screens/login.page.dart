import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter2laravel8/models/user.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  // final _formKeys = GlobalKey<FormBuilderState>();
  final _formKeys = GlobalKey<FormBuilderState>();
  final textControllers = TextEditingController();
  User? _user;
  bool _isLoad = false;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    var user = await getUserFromPref();
    setState(() {
      _user = user;
    });
  }

  Future<User?> getUserFromPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginData = prefs.getString('loginData');
    if (loginData != null && loginData.isNotEmpty) {
      var mapData = json.decode(loginData);
      if (mapData != null && mapData.containsKey('user')) {
        var user = User.fromJson(mapData['user']);
        return user;
      }
    }
    return null;
  }

  Future<String?> getTokenFromPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginData = prefs.getString('loginData');
    if (loginData != null && loginData.isNotEmpty) {
      var mapData = json.decode(loginData);
      if (mapData != null && mapData.containsKey('user')) {
        return mapData['token'] ?? '';
      }
    }
    return null;
  }

  void _login(Map<String, dynamic> formData) async {
    try {
      setState(() {
        _isLoad = true;
      });
      String url = BASE_API_URL + '/login';
      print(url);
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      // var body = json.encode({"email": "iamwad@gmail.com", "password": "1234"});
      var body = json.encode(formData);
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // var parsed = json.decode(response.body);
        // print(parsed);
        // // var user = User.fromJson(parsed['user']);
        // setState(() {
        //   _user = User.fromJson(parsed['user']);
        // });
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loginData', response.body);
        var user = await getUserFromPref();
        setState(() {
          _user = user;
        });
        inspect(_user);
        showDialogBox('Login successed!', 'เข้าสู่ระบบสำเร็จ!');
      } else {
        print('Could not post data. @ login.page._login()');
        showDialogBox('Login failed!', 'ไม่สามารถเข้าสู่ระบบได้');
      }
    } catch (e) {
      print('error on login.page._login() => $e');
    } finally {
      setState(() {
        _isLoad = false;
      });
    }
  }

  _logout() async {
    try {
      String url = BASE_API_URL + '/logout';
      var token = await getTokenFromPref();
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final response = await http.post(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('loginData');
        var user = await getUserFromPref();
        setState(() {
          _user = user;
        });
        showDialogBox('Logout success!', 'ออกจากระบบเรียบร้อย');
      } else {
        print(response.body);
        showDialogBox('Logout failed!',
            'ไม่สามารถออกจากระบบได้ status:${response.statusCode} \n(token อาจจะถูกลบไปแล้ว)');
      }
    } catch (e) {
      print(e);
    }
  }

  void signIn(BuildContext context) async {
    _formKeys.currentState!.save();
    if (_formKeys.currentState!.validate()) {
      print(_formKeys.currentState!.value);
      _login(_formKeys.currentState!.value);
    } else {
      print("validation failed");
      showDialogBox('Validation failed!', 'ข้อมูลไม่ครบถ้วย');
    }
  }

  void showDialogBox(String title, String body) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(body)],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("ปิด"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: _user != null
            ? Container(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Text('User Info',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Username :',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45)),
                      Text(' ${_user!.username ?? ''}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              color: Colors.red)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Email :',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45)),
                      Text(' ${_user!.email ?? ''}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              color: Colors.red)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Fullname :',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45)),
                      Text(' ${_user!.fullname ?? ''}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              color: Colors.red)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Telephone :',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45)),
                      Text(' ${_user!.tel ?? ''}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              color: Colors.red)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Role : ',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black45)),
                      Text(' ${_user!.role.toString()}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                              color: Colors.red)),
                    ],
                  ),
                  SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 72.0,
                    ),
                    label: Text('Logout',
                        style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ]),
              )
            : Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('เข้าสู่ระบบ Laravel8 api',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FormBuilder(
                        key: _formKeys,
                        initialValue: {
                          'email': '',
                          'password': '',
                        },
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: <Widget>[
                            FormBuilderTextField(
                              name: "email",
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  errorStyle: TextStyle(color: Colors.white)),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.email(context),
                              ]),
                            ),
                            SizedBox(height: 20),
                            FormBuilderTextField(
                              name: "password",
                              maxLines: 1,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  errorStyle: TextStyle(color: Colors.white)),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.min(context, 4),
                              ]),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: size.width * 1,
                              height: 72,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0.0,
                                      child: !_isLoad
                                          ? Container(
                                              width: 20.0,
                                              height: 20.0,
                                              child:
                                                  CircularProgressIndicator())
                                          : SizedBox.shrink(),
                                    ),
                                    Center(
                                      child: Text('Log In',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                                onPressed: () => signIn(context),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
