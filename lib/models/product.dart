class Product {
  int id;
  String name;
  int quantity;
  String unit;
  bool isPurchased;
  int listId;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    required this.listId
  });

  factory Product.fromDatabase(Map<String, dynamic> map) => Product(
    id: map['id']?.toInt() ?? 0,
    name: map['name'] ?? '',
    quantity: map['quantity']?.toInt() ?? 0,
    unit: map['unit'] ?? '',
    listId: map['list_id']?.toInt() ?? 0,
    isPurchased: (map['is_purchased'] == 1) ? true : false,
  );
}
