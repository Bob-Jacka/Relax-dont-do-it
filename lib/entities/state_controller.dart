import 'package:relax_dont_do_it/data/app_data.dart';

abstract final class StateAdvices {
  final String physical_pain_advice = '';
  final String nausea_pain_advice = '';
  final String head_pain_advice = '';

  final String special_event_advice = '';
}

final class StateController {
  StateController();

  String make_state_decision({required Set<ConditionStateModifier> modifiers}) {
    return '';
  }
}
