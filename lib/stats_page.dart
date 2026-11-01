import 'package:flutter/material.dart';
import 'package:relax_dont_do_it/measure_model.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var measures = initializeStats();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Relax'),
      ),
      body: Column(children: <_ViewWidget>[measures]),
    );
  }

  //Initialize measure results in list view
  List<_ViewWidget> initializeStats() {
    return [];
  }
}

//One measure widget
class _ViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: Row(children: [Text(data), Text(data)]));
  }
}
