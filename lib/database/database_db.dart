import 'package:sqflite/sqflite.dart';
import 'package:store_list/database/database_service.dart';
import 'package:store_list/models/product.dart';
import 'package:store_list/models/shopping_list.dart';


class DatabaseDB {
  final listTable = 'shopping_lists';
  final productTable = 'products';

  Future<void> createTable(Database database) async {
    await database.execute(
        """CREATE TABLE IF NOT EXISTS $listTable (
           "id" INTEGER PRIMARY KEY,
           "name" VARCHAR(255),
           "created_at" INTEGER
        );"""
    );
    await database.execute(
        """CREATE TABLE IF NOT EXISTS $productTable (
           "id" INTEGER PRIMARY KEY,
           "name" VARCHAR(255),
           "quantity" INTEGER,
           "unit" VARCHAR(255),
           "is_purchased" INTEGER NOT NULL CHECK (is_purchased IN (0, 1)),
           "list_id" INTEGER,
           FOREIGN KEY ("list_id") REFERENCES $listTable("id")
        );"""
    );

  }

  Future<List<ShoppingList>> fetchAll() async {
    final database = await DatabaseService().database;
    final shoppingListsData = await database.rawQuery(
        '''SELECT * from $listTable'''
    );

    List<ShoppingList> shoppingLists = [];

    for(var list in shoppingListsData) {
      List<Product> products = await fetchProducts(list['id'] as int);
      ShoppingList shoppingList = ShoppingList.fromDatabase(list, products);
      shoppingLists.add(shoppingList);
    }
    return shoppingLists;
  }

  Future<List<Product>> fetchProducts(int listId) async {
    final database = await DatabaseService().database;
    final productMap = await database.query(
      productTable,
      where: 'list_id = ?',
      whereArgs: [listId],
    );
    return productMap.map((map) => Product.fromDatabase(map)).toList();
  }

  Future<int> createList({required String listName}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $listTable (name,created_at) VALUES (?,?)''',
      [listName, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<void> deleteList({required  int id}) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
      '''DELETE FROM $listTable WHERE id = ?''',
      [id],
    );
    await database.rawDelete(
      '''DELETE FROM $productTable WHERE list_id = ?''',
      [id],
    );
  }

  Future<int> updateList({required int id, String? name}) async {
    final database = await DatabaseService().database;
    return await database.update(
      listTable,
      {
        if (name != null) 'name': name,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<int> updateProduct({
    required int id,
    required String name,
    required int quantity,
    required String unit
  }) async {
    final database = await DatabaseService().database;
    return await database.update(
      productTable,
      {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<int> createProduct({
    required String name,
    required int quantity,
    required String unit,
    required int listId
  }) async {
    final database = await DatabaseService().database;
    return await database.insert(
      productTable,
      {
        'name' : name,
        'quantity': quantity,
        'unit' : unit,
        'is_purchased' : 0,
        'list_id' : listId,
      },
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  Future<void> changeProductStatus({
    required int id,
    required bool isPurchased
  }) async {
    final database = await DatabaseService().database;
    await database.update(
      productTable,
      {'is_purchased': isPurchased ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteProduct({required int id}) async {
    final database = await DatabaseService().database;
    await database.rawDelete(
      '''DELETE FROM $productTable WHERE id = ?''',
      [id],
    );
  }

}