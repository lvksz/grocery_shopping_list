import 'product.dart';

class ShoppingList {
  int id;
  String name;
  final List<Product> products;
  String createdAt;

  ShoppingList({
    required this.id,
    required this.name,
    List<Product>? products,
    required this.createdAt
  }) : this.products = products ?? [];

  factory ShoppingList.fromDatabase(Map<String, dynamic> map, List<Product> products) => ShoppingList(
    id: map['id']?.toInt() ?? 0,
    name: map['name']?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'])
        .toIso8601String(),
    products: products,
  );
}
