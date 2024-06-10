import 'package:flutter/material.dart';
import 'views/home_screen.dart'; // Asumując, że HomeScreen to ekran główny aplikacji

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData.light(), // Domyślny jasny motyw
      darkTheme: ThemeData.dark(), // Domyślny ciemny motyw
      themeMode: ThemeMode.system, // Użyj motywu zgodnego z ustawieniami systemu
      home: HomeScreen(), // Ekran główny aplikacji
    );
  }


}
