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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home page'),
              Tab(
                icon: Icon(Icons.directions_transit),
                text: 'Statistics page',
              ),
              Tab(icon: Icon(Icons.settings), text: 'Settings page'),
            ],
          ),
          title: Text('Relax'),
        ),
        body: TabBarView(children: [HomePage(), StatsPage(), SettingsPage()]),
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
    dbConnector.insertMeasure(MeasureModel(data: _measure_state, date: DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 113, 114, 115).withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('How are you feeling yourself today?:', maxLines: 1,),
            const SizedBox(height: 50), //just spacer
            const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mood_bad, size: 50), //bad mood
                Icon(Icons.sentiment_neutral, size: 50), //neutral mood
                Icon(Icons.mood, size: 50), //good mood
              ],
            ),
            Text(
              _measure_state.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium, //value user output
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
                  value: ConditionStateModifier.PHYSICAL_PAIN,
                  label: Text('Physical pain'),
                  icon: Icon(Icons.sick),
                ),
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier.HEAD_ACHE,
                  label: Text('Head ache'),
                  icon: Icon(Icons.psychology),
                ),
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier.SPECIAL_EVENT,
                  label: Text('Special event'),
                  icon: Icon(Icons.star),
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
            FloatingActionButton(onPressed: addMeasure, child: Icon(Icons.add),) //to add measures to the database
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Text('Settings'), ListView()]));
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var measures = initializeStats();
    return Scaffold(body: Column(children: measures));
  }

  ///Initialize measure results in list view
  List<ViewWidget> initializeStats() {
    List<Map<String, Object?>> db_req_data = [];
    List<ViewWidget> created_widgets = [];
    dbConnector.selectMeasures().then((value) => db_req_data = value);
    for (var _ in db_req_data) {
      created_widgets.add(ViewWidget());
    }
    return created_widgets;
  }
}

//One measure widget
class ViewWidget extends StatelessWidget {
  const ViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(''), Text('')],);
  }
}
