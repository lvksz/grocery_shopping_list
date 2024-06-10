import 'package:flutter/material.dart';
import '/models/product.dart';

Future<void> showEditProductDialog(
    BuildContext context,
    Product product,
    Function(
        String name,
        String quantity,
        String unit,
        ) onSave,
    ) async {
  TextEditingController nameController = TextEditingController(text: product.name);
  TextEditingController quantityController = TextEditingController(text: product.quantity.toString());
  TextEditingController unitController = TextEditingController(text: product.unit);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(75, 70, 70, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Center(
          child: Text(
            "Edytuj produkt",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nazwa produktu',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            TextField(
              controller: quantityController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Ilość',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            TextField(
              controller: unitController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Jednostka',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(103, 98, 104, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          TextButton(
            child: const Text('Zapisz', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await onSave(
                nameController.text,
                quantityController.text,
                unitController.text,
              );
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
