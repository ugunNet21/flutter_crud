import 'package:flutter/material.dart';
import 'package:flutter_crud/services/api_service.dart';
import 'product_form_page.dart';  // Make sure this import is correct

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List> products;

  @override
  void initState() {
    super.initState();
    products = ApiService().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: FutureBuilder<List>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final productList = snapshot.data ?? [];
          return ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text(product['price'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to the form with product data for editing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductFormPage(
                              isEdit: true,
                              product: product,
                            ),
                          ),
                        ).then((_) {
                          setState(() {
                            products = ApiService().getProducts();
                          });
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await ApiService().deleteProduct(product['id']);
                        setState(() {
                          products = ApiService().getProducts();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the form page to add a new product
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductFormPage(isEdit: false),
            ),
          ).then((_) {
            setState(() {
              products = ApiService().getProducts();
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
