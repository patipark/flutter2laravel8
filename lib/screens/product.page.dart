import 'package:flutter/material.dart';
import 'package:flutter2laravel8/constant.dart';

import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  ProductPage({Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    _fetchProducts();
    super.initState();
  }

  void _fetchProducts() async {
    try {
      String url = BASE_API_URL + '/products';
      print(url);
      String accessToken = ''; // get from sharedpreference
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var loginData = prefs.getString('loginData');
      if (loginData != null && loginData.isNotEmpty) {
        var mapData = json.decode(loginData);
        if (mapData != null) {
          accessToken = mapData.containsKey('token') ? mapData['token'] : '';
        }
      }
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final response = await http.get(Uri.parse(url), headers: headers);
      // print(response.body);
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);
        print(parsed);
      } else {
        print('Could not load data. @ product.page._fetchProducts()');
        throw Exception('ไม่สามารถโหลดข้อมูลจาก API ได้ (Error Code:' +
            response.statusCode.toString() +
            ')');
      }
    } catch (e) {
      print('error on product.page._fetchProducts() => $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Product page'),
    );
  }
}
