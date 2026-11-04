import 'package:flutter/material.dart';
import 'package:relax_dont_do_it/data/app_data.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: addMeasure,
        tooltip: 'Add measure',
        child: const Icon(Icons.add),
      ),
    );
  }

  //Add measure to the database
  void addMeasure() {}
}

class _MeasureWidget extends StatefulWidget {
  @override
  State<_MeasureWidget> createState() => _MeasureWidgetState();
}

class _MeasureWidgetState extends State<_MeasureWidget> {
  double _state = 0;
  Set<ConditionStateModifier> _selected_modifiers = {};

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 113, 114, 115).withValues(alpha: 0.5),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('How are you feeling yourself today?:'),
            SizedBox(height: 50), //just spacer
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mood_bad, size: 50),
                Icon(Icons.mood, size: 50),
              ],
            ),
            Text(
              _state.toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium, //value user output
            ),
            Slider(
              min: min_value,
              max: max_value,
              value: _state, //change for later measure units
              onChanged: (double newValue) {
                setState(() {
                  _state = newValue; // update var when move slider
                });
              },
            ),
            SizedBox(height: 50),
            Text('State modifiers:'),
            SegmentedButton<ConditionStateModifier>(
              segments: const <ButtonSegment<ConditionStateModifier>>[
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier.PHYSICAL_PAIN,
                  label: Text('Physical pain'),
                  icon: Icon(Icons.calendar_view_day),
                ),
                ButtonSegment<ConditionStateModifier>(
                  value: ConditionStateModifier.HEAD_ACHE,
                  label: Text('Head ache'),
                  icon: Icon(Icons.calendar_view_day),
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
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
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

    return Scaffold(body: Column(children: <_ViewWidget>[]));
  }

  ///Initialize measure results in list view
  List<_ViewWidget> initializeStats() {
    return [];
  }
}

//One measure widget
class _ViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: Row());
  }
}
