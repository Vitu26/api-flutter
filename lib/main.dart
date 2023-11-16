import 'package:app_api/product_add.dart';
import 'package:app_api/product_deatils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductsPage(),
    );
  }
}

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('https://api-rest.maxima.inf.br/api/products'));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _products = jsonResponse['products'];
          _isLoading = false;
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _refresh() async {
    await _fetchProducts();
  }

  Future<void> _editProduct(int productId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(productId: productId),
      ),
    ).then((_) => _fetchProducts()); 
  }

  Future<void> _deleteProduct(int productId) async {

    final response = await http.delete(
        Uri.parse('https://api-rest.maxima.inf.br/api/products/$productId'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully')));
      _fetchProducts(); // Recarrega a lista após a exclusão
    } else {
      print('Failed to delete product: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  var product = _products[index];
                  return ListTile(
                    title: Text(product['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: () => _editProduct(product['id']),
                  ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteProduct(product['id']);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      int productId = int.parse(product['id'].toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsPage(productId: productId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
