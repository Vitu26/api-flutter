import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  ProductDetailsPage({required this.productId});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  var _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

Future<void> _fetchProduct() async {
  try {
    final response = await http.get(Uri.parse('https://api-rest.maxima.inf.br/api/products'));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var productsList = jsonResponse['products'] as List;
      
      
      var product = productsList.firstWhere(
        (p) => p['id'] == widget.productId,
        orElse: () => null,
      );

      setState(() {
        _product = product;
        _isLoading = false;
      });
    } else {
      print('Failed to load product: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Product Details'),
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : _product != null
            ? Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _product['name'] ?? 'No name',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Quantiade: ${_product['quanty'] ?? 'N/A'}'),
                    Text('Descrição: ${_product['description'] ?? 'N/A'}'),
                    Text('Categoria: ${_product['category'] ?? 'N/A'}'),
                    Text('Preço: \$${_product['value'] ?? 'N/A'}'),
                  ],
                ),
              )
            : Text('Product not found'),
  );
}
}
