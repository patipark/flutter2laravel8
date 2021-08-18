import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter2laravel8/models/user.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;

import '../constant.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKeys = GlobalKey<FormBuilderState>();
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

  Widget _loadding() {
    return Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 5),
            Padding(
                padding: const EdgeInsets.all(0),
                child: Center(child: CircularProgressIndicator())),
          ],
        ));
  }

  void register(BuildContext context) async {
    try {
      _formKeys.currentState!.save();
      if (_formKeys.currentState!.validate()) {
        // print(_formKeys.currentState!.value);
        var formData = {
          ..._formKeys.currentState!.value,
          'role': 2, // normal user. แอแนบ role ไปกับ form
        };
        print(formData);
        _register(formData);
      } else {
        print("validation failed");
        showDialogBox('Validation failed!', 'ข้อมูลไม่ครบถ้วย');
      }
    } catch (e) {
      print(e);
    }
  }

  void _register(Map<String, dynamic> formData) async {
    try {
      setState(() {
        _isLoad = true;
      });
      String url = BASE_API_URL + '/register';
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
        showDialogBox('Register successed!', 'ลงทะเบียนสำเร็จ!');
      } else {
        print('Could not post data. @ register.page._register()');
        showDialogBox(
            'Register failed!', 'ไม่สามารถลงทะเบียนได้ \n${response.body}');
      }
    } catch (e) {
      print('error on register.page._register() => $e');
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Center(
                      child: Text('Resgister',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FormBuilder(
                        key: _formKeys,
                        // {
                        //   "fullname": "ปฏิภาค โสภา",
                        //   "username": "wad",
                        //   "email": "wad@hello.world",
                        //   "password": "1234",
                        //   "password_confirmation": "1234",
                        //   "tel": "0858369955",
                        //   "role": 2
                        // }
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: <Widget>[
                            FormBuilderTextField(
                              name: "username",
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Username",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  errorStyle: TextStyle(color: Colors.white)),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.min(context, 3),
                              ]),
                            ),
                            SizedBox(height: 20),
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
                            FormBuilderTextField(
                              name: "password_confirmation",
                              maxLines: 1,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  labelText: "Confirm Password",
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
                            FormBuilderTextField(
                              name: "fullname",
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Fullname",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  errorStyle: TextStyle(color: Colors.white)),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.min(context, 3),
                              ]),
                            ),
                            SizedBox(height: 20),
                            FormBuilderTextField(
                              name: "tel",
                              maxLines: 1,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Telephone",
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  errorStyle: TextStyle(color: Colors.white)),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(context),
                                FormBuilderValidators.min(context, 3),
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
                                onPressed: () => register(context),
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
