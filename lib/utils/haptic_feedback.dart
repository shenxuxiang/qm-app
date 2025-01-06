import 'package:gaimon/gaimon.dart';

void hapticFeedback([String type = 'selection']) async {
  if (await Gaimon.canSupportsHaptic) {
    switch (type) {
      case 'selection':
        Gaimon.selection();
      case 'error':
        Gaimon.error();
      case 'success':
        Gaimon.success();
      case 'warning':
        Gaimon.warning();
      case 'heavy':
        Gaimon.heavy();
      case 'medium':
        Gaimon.medium();
      case 'light':
        Gaimon.light();
      case 'rigid':
        Gaimon.rigid();
      case 'soft':
        Gaimon.soft();
    }
  }
}
