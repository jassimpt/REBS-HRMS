import 'package:flutter/material.dart';

import '../../../core/constants/text_constants.dart';

class WorkspaceNavigation extends StatelessWidget {
  const WorkspaceNavigation({
    required this.selectedIndex,
    required this.onSelected,
    this.useRail = false,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool useRail;

  @override
  Widget build(BuildContext context) {
    if (useRail) {
      return NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        labelType: NavigationRailLabelType.all,
        groupAlignment: -0.8,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: Text(TextConstants.overview),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule_rounded),
            label: Text(TextConstants.attendance),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: Text(TextConstants.leave),
          ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: TextConstants.overview,
        ),
        NavigationDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule_rounded),
          label: TextConstants.attendance,
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note_rounded),
          label: TextConstants.leave,
        ),
      ],
    );
  }
}
