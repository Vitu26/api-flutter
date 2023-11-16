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
      _fetchProductData(widget.productId!); // Carregar dados para edição
    }
  }

  Future<void> _fetchProductData(int productId) async {
    final response = await http.get(Uri.parse('https://api-rest.maxima.inf.br/api/products/$productId'));
    if (response.statusCode == 200) {
      var productData = json.decode(response.body);
      _nameController.text = productData['name'];
      _quantityController.text = productData['quanty'];
      _descriptionController.text = productData['description'];
      _valueController.text = productData['value'];
      setState(() {
        _selectedCategory = productData['category'];
      });
    } else {
      print('Failed to load product data: ${response.body}');
    }
  }


  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      var url = 'https://api-rest.maxima.inf.br/api/products';
      var method = _isEdit ? http.put : http.post;
      var response = await http.post(
        Uri.parse('https://api-rest.maxima.inf.br/api/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': _nameController.text,
          'quanty': _quantityController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'value': _valueController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product added successfully')));
        Navigator.pop(context); // Go back to previous screen
      } else {
        print("----------------------------------------------");
        print('Failed to add product: ${response.body}');
        print("----------------------------------------------");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add product')));
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
