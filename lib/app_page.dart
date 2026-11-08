import 'dart:io';

import 'package:flutter/material.dart';
import 'package:relax_dont_do_it/data/app_data.dart';
import 'package:relax_dont_do_it/data/measure_model.dart';
import 'package:relax_dont_do_it/entities/db_connector.dart';
import 'package:relax_dont_do_it/entities/state_controller.dart';

//Global entities
late StateController stateController;
late DbConnector dbConnector;

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
    try {
      stateController = StateController();
      dbConnector = DbConnector();
    } on Exception {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failed'),
            content: Text('Database connection failed'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  exit(1); //exit from app in case of database errors
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home page'),
              Tab(icon: Icon(Icons.history), text: 'Statistics page'),
            ],
          ),
          title: Text('Relax'),
        ),
        body: TabBarView(children: [HomePage(), StatsPage()]),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(child: Column(children: [_MeasureWidget()])),
    );
  }
}

class _MeasureWidget extends StatefulWidget {
  @override
  State<_MeasureWidget> createState() => _MeasureWidgetState();
}

class _MeasureWidgetState extends State<_MeasureWidget> {
  double _measure_state = 0; //user selected state
  Set<ConditionStateModifier> _selected_modifiers = {};

  //Add measure to the database
  void addMeasure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adding to the database'),
        duration: Duration(seconds: 2),
      ),
    );
    dbConnector.insertMeasure(
      MeasureModel(data: _measure_state, date: DateTime.now().toString()),
    );
  }

  //Show user some advice on his or her emotional or phycophysical statement
  void showAdvice() {
    final stateAdvice = stateController.make_state_decision(
      modifiers: _selected_modifiers,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Listen to '),
          content: Column(children: [Text('State advice'), Text(stateAdvice)]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 113, 114, 115).withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('How are you feeling yourself today?', maxLines: 1),
            const SizedBox(height: 50), //just spacer
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //bad mood
                AnimatedContainer(
                  color: _measure_state <= 1.5 ? Colors.red : Colors.green,
                  duration: Duration(milliseconds: 300),
                  child: Icon(Icons.mood_bad, size: 50),
                ),

                SizedBox(width: 30), //just spacer
                //good mood
                AnimatedContainer(
                  color: _measure_state <= 3.0 ? Colors.red : Colors.green,
                  duration: Duration(milliseconds: 300),
                  child: Icon(Icons.mood, size: 50),
                ),

                SizedBox(width: 30), //just spacer
                //overdrive mood
                AnimatedContainer(
                  color: _measure_state <= 3.7 ? Colors.red : Colors.green,
                  duration: Duration(milliseconds: 300),
                  child: Icon(Icons.bolt, size: 50),
                  onEnd: () => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Depression warning!'),
                        duration: Duration(seconds: 2),
                      ),
                    ),
                  },
                ),
              ],
            ),

            Row(
              children: [
                Transform.translate(
                  offset: Offset(
                    _measure_state * 70,
                    0,
                  ), //move text to the cursor
                  child: Text(
                    _measure_state.toStringAsFixed(2),
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium, //value user output
                  ),
                ),
              ],
            ),

            Slider(
              min: min_value,
              max: max_value,
              value: _measure_state, //change for later measure units
              onChanged: (double newValue) {
                setState(() {
                  _measure_state = newValue; // update var when move slider
                });
              },
            ),

            const SizedBox(height: 50),
            const Text('State modifiers:'),
            SegmentedButton<ConditionStateModifier>(
              segments: const <ButtonSegment<ConditionStateModifier>>[
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier
                      .PHYSICAL_PAIN, //Физическая боль, например болят мышцы
                  label: Text('Physical pain'),
                  icon: Icon(Icons.sick),
                ),
                ButtonSegment<ConditionStateModifier>(
                  value:
                      ConditionStateModifier.HEAD_ACHE, //Просто головная боль
                  label: Text('Head ache'),
                  icon: Icon(Icons.psychology),
                ),
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier
                      .SPECIAL_EVENT, //Какое то особое событие
                  label: Text('Special event'),
                  icon: Icon(Icons.star),
                ),
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier.NAUSEA,
                  label: Text('Nausea'),
                  icon: Icon(Icons.sick), //Тошнота
                ),
              ],
              selected: _selected_modifiers,
              onSelectionChanged: (Set<ConditionStateModifier> newSelection) {
                setState(() {
                  _selected_modifiers = newSelection;
                });
              },
              multiSelectionEnabled: true,
              emptySelectionAllowed: true,
            ),
            const SizedBox(height: 50), //just spacer
            Align(
              alignment: AlignmentGeometry.bottomRight,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: addMeasure,
                    child: Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: showAdvice,
                    child: Icon(Icons.live_help),
                  ),
                ],
              ),
            ), //to add measures to the database
          ],
        ),
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MeasureListWidget());
  }
}

class MeasureListWidget extends StatefulWidget {
  const MeasureListWidget({super.key});

  @override
  State<MeasureListWidget> createState() => _MeasureListWidget();
}

class _MeasureListWidget extends State<MeasureListWidget> {
  final List<MeasureModel> _measures = [];

  @override
  void initState() {
    super.initState();
    int counter = 0;
    dbConnector.selectMeasures().then((value) {
      setState(() {
        var data = value[counter]['data'] as double;
        var date = value[counter]['date'] as String;
        _measures.add(MeasureModel(data: data, date: date));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_measures.isEmpty) {
      return Center(child: Text('Загружаем...'));
    }
    return ListView.builder(
      itemCount: _measures.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            'Data: ${_measures[index].date.substring(0, 19)} with measures: ${_measures[index].data}',
          ),
          onLongPress: () => {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Available actions:'),
                  content: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          dbConnector.deleteMeasure(
                            id: index,
                          ); //attach index of the list tile
                          SnackBar(
                            content: Text('Deleting from the database'),
                            duration: Duration(seconds: 2),
                          );
                        },
                        child: Text('Delete measure'),
                      ),
                      TextButton(
                        onPressed: () {
                          dbConnector.updateMeasure(_measures[index]);
                          SnackBar(
                            content: Text('Updating entity in database'),
                            duration: Duration(seconds: 2),
                          );
                        },
                        child: Text('Update measure'),
                      ),
                    ],
                  ),
                );
              },
            ),
          },
        );
      },
    );
  }
}
