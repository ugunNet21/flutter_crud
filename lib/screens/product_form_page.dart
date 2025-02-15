import 'package:flutter/material.dart';
import 'package:flutter_crud/services/api_service.dart';

class ProductFormPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? product;

  ProductFormPage({required this.isEdit, this.product});

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final name = _nameController.text;
                    final price = double.parse(_priceController.text);

                    final productData = {
                      'name': name,
                      'price': price,
                    };

                    if (widget.isEdit && widget.product != null) {
                      await ApiService().updateProduct(widget.product!['id'], productData);
                    } else {
                      await ApiService().createProduct(productData);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.isEdit ? 'Update Product' : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
