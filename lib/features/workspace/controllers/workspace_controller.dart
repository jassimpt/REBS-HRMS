import 'package:flutter/foundation.dart';

import '../states/workspace_state.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceState _state = const WorkspaceState();

  WorkspaceState get state => _state;

  // Changes the active workspace section.
  void selectSection(int index) {
    final section = WorkspaceSection.values[index];
    if (section == _state.section) return;

    _state = WorkspaceState(section: section);
    notifyListeners();
  }
}
