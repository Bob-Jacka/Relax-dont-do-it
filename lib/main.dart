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
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      body: SizedBox.expand(child: Column(children: [_MeasureWidget()])),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MeasureWidget extends StatefulWidget {
  @override
  State<_MeasureWidget> createState() => _MeasureWidgetState();
}

class _MeasureWidgetState extends State<_MeasureWidget> {
  double _state = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(
        255,
        113,
        114,
        115,
      ).withValues(alpha: 0.5),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 97,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const Text('How are you feeling yourself today?:'),
		  SizedBox(height: 50), //just spacer
          Row(
			mainAxisSize: MainAxisSize.min,
			mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.mood_bad), Icon(Icons.mood)],
          ),
          Text(
            '${((_state * 100.0).round()) / 100.0}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Slider(
            min: 0.0,
            max: 5.0,
            value: _state, //change for later measure units
            onChanged: (double newValue) {
              setState(() {
                _state = newValue; // update var when move slider
              });
            },
          ),
        ],
      ),
    );
  }
}
