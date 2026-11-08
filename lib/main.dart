import 'package:flutter/material.dart';
import 'package:relax_dont_do_it/app_page.dart';

void main() {
  runApp(const RelaxApp());
}

class RelaxApp extends StatelessWidget {
  const RelaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relax do not do it',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 218, 225, 22))),

      routes: {'/': (context) => AppPage()},
    );
  }
}
