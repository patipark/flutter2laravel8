import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter2laravel8/constant.dart';
import 'package:flutter2laravel8/models/product.dart';

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
    // _fetchProducts();
    super.initState();
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

  Future<List<Product>?> _fetchProducts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      String url = BASE_API_URL + '/products';
      var token = await getTokenFromPref();
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final response = await http.get(Uri.parse(url), headers: headers);
      // print(response.body);
      if (response.statusCode == 200) {
        List parsed = json.decode(response.body);
        return parsed.map((json) => new Product.fromJson(json)).toList();
      } else {
        print('Could not load data. @ product.page._fetchProducts()');
        showDialogBox('Load Product failed!',
            'ไม่สามารถโหลดข้อมูลจาก API ได้ status:${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('error on product.page._fetchProducts() => $e');
      return null;
    }
  }

  dynamic buildList(List<Product> products) {
    return ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          Product product = products[index];
          inspect(product);
          return ListTile(
            leading: Icon(Icons.album),
            title: Text(
              '${index + 1}. ${product.name ?? ''}',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Price : ${product.price ?? ''} บาท',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Description : ${product.description ?? ''}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Slug : ${product.slug ?? ''}',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        });
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

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          // width: size.width * 0.9,
          padding: EdgeInsets.all(10),
          child: Center(
              child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Text('Product List',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
              ),
              Expanded(
                  flex: 9,
                  child: Container(
                    child: FutureBuilder(
                      future: _fetchProducts(), //_getJobOrder(_selectedDay!),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        print('snapshot.error ==> ${snapshot.error}');
                        print(
                            'snapshot.connectionState=${snapshot.connectionState}');
                        print('snapshot.hasData ==> ${snapshot.hasData}');
                        print('snapshot.data ==> ${snapshot.data}');
                        if (snapshot.hasData) {
                          // List<Customer> customer = customerFromJson(
                          //     convert.jsonEncode(snapshot.data['data']));
                          // print(customer.length);
                          return buildList(snapshot.data);
                        }
                        return _loadding();
                      },
                    ),
                  )),
            ],
          )),
        ),
      ),
    );
  }
}
