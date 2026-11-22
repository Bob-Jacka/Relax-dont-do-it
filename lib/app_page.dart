import 'dart:io';

import 'package:flutter/material.dart';
import 'package:relax_dont_do_it/data/app_data.dart';
import 'package:relax_dont_do_it/data/app_settings.dart';
import 'package:relax_dont_do_it/data/measure_model.dart';
import 'package:relax_dont_do_it/entities/db_connector.dart';
import 'package:relax_dont_do_it/entities/state_controller.dart';

//Global entities
late StateController stateController;
late DbConnector dbConnector;

late ConditionStateModifier stateModifier;

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
      //show on all exceptions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Failed'),
            content: const Text('Database connection failed'),
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home page'),
              Tab(icon: Icon(Icons.history), text: 'Statistics page'),
              Tab(icon: Icon(Icons.history), text: 'Settings page'),
            ],
          ),
          title: Text('Relax'),
        ),
        body: TabBarView(children: [HomePage(), StatsPage(), SettingPage()]),
      ),
    );
  }
}

Future<double> build_input_dialog({
  required BuildContext context,
  required double old_value,
}) async {
  TextEditingController _textFieldController = TextEditingController();
  late String user_input;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter new value for setting:'),
        content: TextField(
          controller: _textFieldController,
          decoration: InputDecoration(
            hintText: 'Enter new value, old was "$old_value"',
          ),
          onChanged: (value) => user_input = value,
          onEditingComplete: () {},
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              if (user_input.isEmpty) {
                throw Exception(
                  'Model data cannot be null',
                ); //TODO solve this problem
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              if (user_input.isEmpty) {
                throw Exception(
                  'Model data cannot be null',
                ); //TODO solve this problem
              } else {
                debugPrint(_textFieldController.text);
                Navigator.of(context).pop(user_input);
              }
            },
          ),
        ],
      );
    },
  );
  return double.parse(user_input);
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          children: [
            Align(
              alignment: AlignmentGeometry.topLeft,
              child: Padding(
                padding: EdgeInsetsGeometry.all(5),
                child: const Text(
                  'Settings:',
                  style: TextStyle(fontWeight: FontWeight(700)),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsetsGeometry.all(5),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Low level: $low_level_edge'),
                      onTap: () async => {
                        low_level_edge = await build_input_dialog(
                          context: context,
                          old_value: low_level_edge,
                        ),
                      },
                    ),
                    ListTile(
                      title: Text('Medium level: $medium_level_edge'),
                      onTap: () async => {
                        medium_level_edge = await build_input_dialog(
                          context: context,
                          old_value: medium_level_edge,
                        ),
                      },
                    ),
                    ListTile(
                      title: Text('high_level_edge level: $high_level_edge'),
                      onTap: () async => {
                        high_level_edge = await build_input_dialog(
                          context: context,
                          old_value: high_level_edge,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            const Text(
              'How are you feeling yourself today?',
              style: TextStyle(fontWeight: FontWeight(700)), //bold style
              maxLines: 1,
            ),
            const SizedBox(height: 50), //just spacer
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //bad mood
                AnimatedContainer(
                  color: _measure_state <= low_level_edge
                      ? Colors.red
                      : Colors.green,
                  duration: Duration(milliseconds: 300),
                  child: Icon(Icons.mood_bad, size: 50),
                ),

                const SizedBox(width: 30), //just spacer
                //good mood
                AnimatedContainer(
                  color: _measure_state <= medium_level_edge
                      ? Colors.red
                      : Colors.green,
                  duration: Duration(milliseconds: 300),
                  child: Icon(Icons.mood, size: 50),
                ),

                const SizedBox(width: 30), //just spacer
                //overdrive mood
                AnimatedContainer(
                  color: _measure_state <= high_level_edge
                      ? Colors.red
                      : Colors.green,
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
                    _measure_state * 70, //magic constant
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

            const Text(
              'State modifiers:',
              style: TextStyle(fontWeight: FontWeight(700)),
            ),
            DropdownMenu<ConditionStateModifier>(
              width: MediaQuery.of(context).size.width - 10,
              dropdownMenuEntries: [
                DropdownMenuEntry<ConditionStateModifier>(
                  value: ConditionStateModifier.NONE,
                  label: 'No modifier',
                  leadingIcon: Icon(Icons.no_adult_content_sharp),
                ),
                DropdownMenuEntry<ConditionStateModifier>(
                  value: ConditionStateModifier.PHYSICAL_PAIN,
                  label: 'Physical pain',
                  leadingIcon: Icon(Icons.sick),
                ),
                DropdownMenuEntry<ConditionStateModifier>(
                  value: ConditionStateModifier.HEAD_ACHE,
                  label: 'Head ache',
                  leadingIcon: Icon(Icons.psychology),
                ),
                DropdownMenuEntry<ConditionStateModifier>(
                  value: ConditionStateModifier.SPECIAL_EVENT,
                  label: 'Special event',
                  leadingIcon: Icon(Icons.star),
                ),
                DropdownMenuEntry<ConditionStateModifier>(
                  value: ConditionStateModifier.NAUSEA,
                  label: 'Nausea',
                  leadingIcon: Icon(Icons.sick),
                ),
                DropdownMenuEntry<ConditionStateModifier>(
                  value: ConditionStateModifier.RED_EYES,
                  label: 'Red eyes',
                  leadingIcon: Icon(Icons.remove_red_eye),
                ),
              ],
              onSelected: (value) => {},
            ),

            const SizedBox(height: 50), //just spacer
            Align(
              alignment: AlignmentGeometry.bottomRight,
              child: Padding(
                padding: EdgeInsetsGeometry.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
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
                              content: const Text('Deleting from the database'),
                              duration: Duration(seconds: 2),
                            );
                          },
                          child: Text('Delete measure'),
                        ),
                        TextButton(
                          onPressed: () {
                            dbConnector.updateMeasure(_measures[index]);
                            SnackBar(
                              content: const Text(
                                'Updating entity in database',
                              ),
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
          ),
        );
      },
    );
  }
}
