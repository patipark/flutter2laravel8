import 'package:flutter/material.dart';
import 'package:flutter2laravel8/screens/register.page.dart';
import 'login.page.dart';
import 'product.page.dart';

class RootPage extends StatefulWidget {
  RootPage({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();
    //do stuff here
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Flutter2 Laravel8")),
          // actions: [
          //   TextButton(
          //     child: Text(
          //       "Login",
          //       style: TextStyle(
          //         color: Colors.white,
          //       ),
          //     ),
          //     onPressed: () {
          //       // Navigator.of(context).pushNamed('/login');
          //       print('Login');
          //     },
          //   ),
          //   TextButton(
          //     child: Text(
          //       "Logout",
          //       style: TextStyle(
          //         color: Colors.white,
          //       ),
          //     ),
          //     onPressed: () {
          //       // Navigator.of(context).pushNamed('/logout');
          //       print('Logout');
          //     },
          //   ),
          // ],
          bottom: TabBar(
            indicatorWeight: 10.0,
            labelStyle: Theme.of(context).textTheme.headline6,
            tabs: <Widget>[
              Tab(
                text: "Login",
              ),
              Tab(
                text: "Register",
              ),
              Tab(
                text: "Product",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            LoginPage(),
            RegisterPage(),
            ProductPage(),
          ],
        ),
      ),
    );
  }
}
