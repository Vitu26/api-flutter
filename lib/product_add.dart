import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductPage extends StatefulWidget {
  final int? productId; // Pode ser nulo para adição, não nulo para edição

  AddProductPage({Key? key, this.productId}) : super(key: key);
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedCategory = 'Selecione a categoria';
  final List<String> _categories = [
    'Selecione a categoria',
    'limpeza',
    'alimentação',
    'materiais de construção',
    'produtos industriais',
    'teste',
  ];

  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _isEdit = true;
      _fetchProductData(widget.productId!);
    }
  }

  Future<void> _fetchProductData(int productId) async {
    final response = await http.get(
        Uri.parse('https://api-rest.maxima.inf.br/api/products/$productId'));
    if (response.statusCode == 200) {
      var productData = json.decode(response.body);
      print("Product Data: $productData"); // Imprimir os dados do produto

      _nameController.text = productData['name'] ?? '';
      _quantityController.text = productData['quanty']?.toString() ?? '';
      _descriptionController.text = productData['description'] ?? '';
      _valueController.text = productData['value']?.toString() ?? '';
      setState(() {
        _selectedCategory = productData['category'] ?? _selectedCategory;
      });
    } else {
      print('Failed to load product data: ${response.body}');
    }
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      var url = _isEdit
          ? 'https://api-rest.maxima.inf.br/api/products/${widget.productId}'
          : 'https://api-rest.maxima.inf.br/api/products';

      var response = await (_isEdit ? http.put : http.post)(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': _nameController.text,
          'quanty': _quantityController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'value': _valueController.text,
        }),
      );

      if (_isEdit ? response.statusCode == 200 : response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEdit
                  ? 'Product updated successfully'
                  : 'Product added successfully')),
        );
        Navigator.pop(context);
      } else {
        print("----------------------------------------------");
        print('Failed to add/edit product: ${response.body}');
        print("----------------------------------------------");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == 'Selecione a categoria') {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Value'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter value';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _submitProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
