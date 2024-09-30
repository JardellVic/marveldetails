import 'package:flutter/material.dart';
import 'telas/lista_personagem.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MarvelApp());
}

class MarvelApp extends StatefulWidget {
  const MarvelApp({super.key});

  @override
  _MarvelAppState createState() => _MarvelAppState();
}

class _MarvelAppState extends State<MarvelApp> {
  bool isDarkTheme = true;

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt', ''),
      ],
      title: 'UNIVERSO MARVEL',
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: CharactersListScreen(
        isDarkTheme: isDarkTheme,
        toggleTheme: toggleTheme,
      ),
    );
  }
}
