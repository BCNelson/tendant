import 'package:flutter/material.dart';

void main() {
  runApp(const TendantApp());
}

class TendantApp extends StatelessWidget {
  const TendantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tendant',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('tendant')),
      body: const Center(child: Text('Hello, tendant!')),
    );
  }
}
