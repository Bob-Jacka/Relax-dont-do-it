import 'package:flutter/material.dart';
import 'package:relax_dont_do_it/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relax do not do it',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomePage(),
      initialRoute: '/',
      routes: {
        '/':(context) => HomePage(),
        '/settings': (context) => SettingsPage()
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _counter = 0;

  void _incrementHumanState(double newVal) {
    _counter = newVal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Relax'),
      ),
      drawer: NavigationDrawer(
        children: <Widget>[
          Text('Option 1'),
          Text('Option 2'),
          Text('Option 3'),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Slider(
              value: 0,
              onChanged: _incrementHumanState,
              min: 0.0,
              max: 5.0,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementHumanState,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
