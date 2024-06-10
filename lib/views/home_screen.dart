import 'package:flutter/material.dart';
import 'package:store_list/database/database_db.dart';
import '../models/shopping_list.dart';
import '../views/shopping_list_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<ShoppingList>>? _shoppingLists;
  final database = DatabaseDB();

  @override
  void initState() {
    super.initState();
    fetchLists();
  }

  void fetchLists() {
    setState(() {
      _shoppingLists = database.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(149, 109, 177, 1),
        title: const Text('Listy zakupów', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ShoppingList>>(
        future: _shoppingLists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak dostępnych list zakupów'));
          } else {
            final shoppingLists = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 14),
              itemCount: shoppingLists.length,
              itemBuilder: (context, index) {
                final shoppingList = shoppingLists[index];
                return Dismissible(
                  key: Key(shoppingList.name),
                  onDismissed: (direction) {
                    _removeShoppingList(shoppingList.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${shoppingList.name} usunięto")),
                    );
                  },
                  background: Container(color: Colors.red),
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
                      title: Text(shoppingList.name, style: const TextStyle(color: Colors.white)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'edit') {
                            _editShoppingListName(shoppingList.id);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edytuj'),
                          ),
                        ],
                        padding: EdgeInsets.zero,
                        child: const Icon(Icons.more_vert),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ShoppingListDetailsScreen(
                                  shoppingList: shoppingList,
                                  onDelete: () => fetchLists(),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: FloatingActionButton.extended(
          backgroundColor: const Color.fromRGBO(149, 109, 177, 1),
          onPressed: _addNewShoppingList,
          label: const Text('Dodaj nową listę', style: TextStyle(fontSize: 18)),
          icon: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: const Color.fromRGBO(79, 73, 73, 1),
    );
  }

  void _removeShoppingList(int id) async {
    await database.deleteList(id: id);
    fetchLists();
  }

  void _addNewShoppingList() async {
    final String? newListName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dodaj nową listę zakupów'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Wpisz nazwę listy'),
            onSubmitted: (String value) {
              Navigator.pop(context, value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );

    if (newListName != null && newListName.isNotEmpty) {
      await database.createList(listName: newListName);
      fetchLists();
    }
  }

  void _editShoppingListName(int id) async {
    List<ShoppingList> shoppingLists = await database.fetchAll();
    ShoppingList? shoppingList = shoppingLists.firstWhere((list) =>
    list.id == id);

    TextEditingController nameController = TextEditingController(
        text: shoppingList.name);

    final String? updatedName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edytuj nazwę listy zakupów'),
          content: TextField(
            autofocus: true,
            controller: nameController,
            decoration: const InputDecoration(
                hintText: 'Wpisz nową nazwę listy'),
            onSubmitted: (String value) {
              Navigator.pop(context, value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Anuluj'),
            ),
          ],
        );
      },
    );
    await database.updateList(id: id, name: updatedName);
    fetchLists();
  }
}
