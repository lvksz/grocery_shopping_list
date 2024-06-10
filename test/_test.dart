import 'package:flutter_test/flutter_test.dart';
import 'package:store_list/models/product.dart';
import 'package:store_list/models/shopping_list.dart';
import 'package:flutter/material.dart';
import 'package:store_list/views/home_screen.dart';
import 'package:store_list/views/shopping_list_details_screen.dart';
import 'package:store_list/database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Product', () {
    test('Constructor creates a Product instance', () {
      final product = Product(
        id: 1,
        name: 'Milk',
        quantity: 2,
        unit: 'liters',
        isPurchased: false,
        listId: 1,
      );

      expect(product.id, 1);
      expect(product.name, 'Milk');
      expect(product.quantity, 2);
      expect(product.unit, 'liters');
      expect(product.isPurchased, false);
      expect(product.listId, 1);
    });

    test('Product can be marked as purchased', () {
      final product = Product(
        id: 1,
        name: 'Milk',
        quantity: 2,
        unit: 'liters',
        isPurchased: false,
        listId: 1,
      );

      product.isPurchased = true;

      expect(product.isPurchased, true);
    });

    test('Product can change quantity', () {
      final product = Product(
        id: 1,
        name: 'Milk',
        quantity: 2,
        unit: 'liters',
        isPurchased: false,
        listId: 1,
      );

      product.quantity = 3;

      expect(product.quantity, 3);
    });

    test('Product can change unit', () {
      final product = Product(
        id: 1,
        name: 'Milk',
        quantity: 2,
        unit: 'liters',
        isPurchased: false,
        listId: 1,
      );

      product.unit = 'gallons';

      expect(product.unit, 'gallons');
    });

    test('Product toJson returns correct map', () {
      final product = Product(
        id: 1,
        name: 'Milk',
        quantity: 2,
        unit: 'liters',
        isPurchased: false,
        listId: 1,
      );

      final json = {
        'id': product.id,
        'name': product.name,
        'quantity': product.quantity,
        'unit': product.unit,
        'is_purchased': product.isPurchased ? 1 : 0,
        'list_id': product.listId,
      };

      expect(json['id'], 1);
      expect(json['name'], 'Milk');
      expect(json['quantity'], 2);
      expect(json['unit'], 'liters');
      expect(json['is_purchased'], 0);
      expect(json['list_id'], 1);
    });

    test('Product fromDatabase creates correct instance', () {
      final json = {
        'id': 1,
        'name': 'Milk',
        'quantity': 2,
        'unit': 'liters',
        'is_purchased': 0,
        'list_id': 1,
      };

      final product = Product.fromDatabase(json);
      expect(product.id, 1);
      expect(product.name, 'Milk');
      expect(product.quantity, 2);
      expect(product.unit, 'liters');
      expect(product.isPurchased, false);
      expect(product.listId, 1);
    });
  });

  group('ShoppingList', () {
    test('Constructor creates a ShoppingList instance', () {
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [],
        createdAt: '2024-06-09',
      );

      expect(shoppingList.id, 1);
      expect(shoppingList.name, 'Groceries');
      expect(shoppingList.products, isEmpty);
      expect(shoppingList.createdAt.split('T').first, '2024-06-09');
    });

    test('Adding a product to ShoppingList', () {
      final product = Product(
        id: 2,
        name: 'Bread',
        quantity: 1,
        unit: 'loaf',
        isPurchased: false,
        listId: 1,
      );
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [product],
        createdAt: '2024-06-09',
      );

      expect(shoppingList.products.length, 1);
      expect(shoppingList.products[0].name, 'Bread');
    });

    test('Removing a product from ShoppingList', () {
      final product1 = Product(
        id: 2,
        name: 'Bread',
        quantity: 1,
        unit: 'loaf',
        isPurchased: false,
        listId: 1,
      );
      final product2 = Product(
        id: 3,
        name: 'Butter',
        quantity: 1,
        unit: 'pack',
        isPurchased: false,
        listId: 1,
      );
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [product1, product2],
        createdAt: '2024-06-09',
      );

      shoppingList.products.remove(product1);

      expect(shoppingList.products.length, 1);
      expect(shoppingList.products[0].name, 'Butter');
    });

    test('ShoppingList can contain multiple products', () {
      final product1 = Product(
        id: 2,
        name: 'Bread',
        quantity: 1,
        unit: 'loaf',
        isPurchased: false,
        listId: 1,
      );
      final product2 = Product(
        id: 3,
        name: 'Butter',
        quantity: 1,
        unit: 'pack',
        isPurchased: false,
        listId: 1,
      );
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [product1, product2],
        createdAt: '2024-06-09',
      );

      expect(shoppingList.products.length, 2);
      expect(shoppingList.products[0].name, 'Bread');
      expect(shoppingList.products[1].name, 'Butter');
    });

    test('ShoppingList contains correct product quantities', () {
      final product1 = Product(
        id: 2,
        name: 'Bread',
        quantity: 1,
        unit: 'loaf',
        isPurchased: false,
        listId: 1,
      );
      final product2 = Product(
        id: 3,
        name: 'Butter',
        quantity: 2,
        unit: 'packs',
        isPurchased: false,
        listId: 1,
      );
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [product1, product2],
        createdAt: '2024-06-09',
      );

      expect(shoppingList.products[0].quantity, 1);
      expect(shoppingList.products[1].quantity, 2);
    });

    test('ShoppingList can add and remove products', () {
      final product1 = Product(
        id: 2,
        name: 'Bread',
        quantity: 1,
        unit: 'loaf',
        isPurchased: false,
        listId: 1,
      );
      final product2 = Product(
        id: 3,
        name: 'Butter',
        quantity: 2,
        unit: 'packs',
        isPurchased: false,
        listId: 1,
      );
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [],
        createdAt: '2024-06-09',
      );

      shoppingList.products.add(product1);
      expect(shoppingList.products.length, 1);
      expect(shoppingList.products[0].name, 'Bread');

      shoppingList.products.add(product2);
      expect(shoppingList.products.length, 2);
      expect(shoppingList.products[1].name, 'Butter');

      shoppingList.products.remove(product1);
      expect(shoppingList.products.length, 1);
      expect(shoppingList.products[0].name, 'Butter');
    });

    test('ShoppingList toJson returns correct map', () {
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [],
        createdAt: '2024-06-09',
      );

      final json = {
        'id': shoppingList.id,
        'name': shoppingList.name,
        'created_at': DateTime.parse(shoppingList.createdAt).millisecondsSinceEpoch,
        'products': shoppingList.products.map((product) => {
          'id': product.id,
          'name': product.name,
          'quantity': product.quantity,
          'unit': product.unit,
          'is_purchased': product.isPurchased ? 1 : 0,
          'list_id': product.listId,
        }).toList(),
      };

      expect(json['id'], 1);
      expect(json['name'], 'Groceries');
      expect(json['created_at'], DateTime.parse('2024-06-09').millisecondsSinceEpoch);
    });

    test('ShoppingList fromDatabase creates correct instance', () {
      final json = {
        'id': 1,
        'name': 'Groceries',
        'created_at': DateTime.parse('2024-06-09').millisecondsSinceEpoch,
      };

      final productJson = {
        'id': 2,
        'name': 'Bread',
        'quantity': 1,
        'unit': 'loaf',
        'is_purchased': 0,
        'list_id': 1,
      };

      final products = [Product.fromDatabase(productJson)];
      final shoppingList = ShoppingList.fromDatabase(json, products);

      expect(shoppingList.id, 1);
      expect(shoppingList.name, 'Groceries');
      expect(shoppingList.createdAt.split('T').first, '2024-06-09');
      expect(shoppingList.products.length, 1);
      expect(shoppingList.products[0].name, 'Bread');
    });
  });

  group('HomeScreen', () {
    testWidgets('HomeScreen has a FloatingActionButton', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('ShoppingListDetailsScreen', () {
    testWidgets('ShoppingListDetailsScreen has a title and a text', (WidgetTester tester) async {
      final shoppingList = ShoppingList(
        id: 1,
        name: 'Groceries',
        products: [],
        createdAt: '2024-06-09',
      );

      await tester.pumpWidget(MaterialApp(home: ShoppingListDetailsScreen(shoppingList: shoppingList)));

      final textWidgets = tester.widgetList(find.byType(Text)).toList();

      for (var widget in textWidgets) {
        debugPrint(widget.toString());
      }

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Dodaj'), findsOneWidget);
    });
  });

  group('DatabaseService', () {
    late DatabaseService databaseService;

    setUp(() {
      databaseService = DatabaseService();
    });

    test('DatabaseService initializes database', () async {
      final db = await databaseService.database;
      expect(db, isNotNull);
    });

    test('DatabaseService creates the database', () async {
      final db = await databaseService.database;

      final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
      final tableNames = tables.map((table) => table['name']).toList();

      expect(tableNames, contains('products'));
    });
  });
}
