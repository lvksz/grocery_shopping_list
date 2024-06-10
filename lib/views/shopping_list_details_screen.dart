import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store_list/views/home_screen.dart';
import 'package:store_list/views/widgets/add_product.dart';
import '../database/database_db.dart';
import '../models/shopping_list.dart';
import '../models/product.dart';
import './widgets/edit_product.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  final ShoppingList shoppingList;
  final Function? onDelete;

  const ShoppingListDetailsScreen({super.key, required this.shoppingList, this.onDelete});

  @override
  _ShoppingListDetailsScreenState createState() => _ShoppingListDetailsScreenState();
}

class _ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product>? _products;
  final database = DatabaseDB();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() {
    _productsFuture = database.fetchProducts(widget.shoppingList.id);
    _productsFuture.then((productList) {
      setState(() {
        _products = productList;
      });
      _checkIfAllProductsPurchased();
    });
  }

  void _editProduct(Product product) async {
    await showEditProductDialog(context, product,
            (String name, String quantity, String unit) async {
          await database.updateProduct(
              id: product.id, name: name, quantity: int.tryParse(quantity) ?? 0, unit: unit);
        });
    fetchProducts();
  }

  void _sortProductsAlphabetically() {
    setState(() {
      _products?.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _sortProductsByQuantity() {
    setState(() {
      _products?.sort((a, b) => a.quantity.compareTo(b.quantity));
    });
  }

  void _changeProductStatus(Product product) async {
    await database.changeProductStatus(id: product.id, isPurchased: !product.isPurchased);
    fetchProducts();
  }

  void _addNewProduct(int listId) async {
    await showAddProductDialog(context, (String name, String quantity, String unit) async {
      await database.createProduct(
        name: name,
        quantity: int.tryParse(quantity) ?? 0,
        unit: unit,
        listId: listId,
      );
    });
    fetchProducts();
  }

  void _checkIfAllProductsPurchased() {
    bool allPurchased = _products?.every((product) => product.isPurchased) ?? false;
    if (allPurchased && _products!.isNotEmpty) {
      _removeShoppingList(widget.shoppingList);
    }
  }

  void _removeShoppingList(ShoppingList shoppingList) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(75, 70, 70, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Center(
            child: Text(
              "Usuń listę",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          content: const Text(
            "Jesteś pewien, że chcesz usunąć Twoją listę zakupów?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(103, 98, 104, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            TextButton(
              child: const Text('Usuń', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await database.deleteList(id: shoppingList.id);
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(149, 109, 177, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(149, 109, 177, 1),
        title: Text(widget.shoppingList.name),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak produktów na tej liście.'));
          }
          List<Product> products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: _products!.length,
            itemBuilder: (context, index) {
              final product = _products![index];
              return Dismissible(
                key: Key(product.name),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await database.deleteProduct(id: product.id);
                  fetchProducts();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Produkt usunięty")));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(119, 119, 119, 1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      product.name,
                      style: TextStyle(
                        color: product.isPurchased ? Colors.red : Colors.white,
                        decoration: product.isPurchased ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      "${product.quantity} ${product.unit}",
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () => _changeProductStatus(product),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            product.isPurchased ? Icons.check_box : Icons.check_box_outline_blank,
                            color: Colors.white,
                          ),
                          onPressed: () => _changeProductStatus(product),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              _editProduct(product);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edytuj'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0), // Adjust this value to shift right
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: FloatingActionButton(
                onPressed: () => _removeShoppingList(widget.shoppingList),
                tooltip: 'Usuń listę zakupów',
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete),
              ),
            ),
            const SizedBox(width: 20), // Space between buttons
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: FloatingActionButton.extended(
                backgroundColor: const Color.fromRGBO(149, 109, 177, 1),
                onPressed: () => _addNewProduct(widget.shoppingList.id),
                tooltip: 'Dodaj produkt',
                icon: const Icon(Icons.add),
                label: const Text('Dodaj'),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(79, 73, 73, 1),
    );
  }
}