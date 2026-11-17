import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/workspace_controller.dart';
import '../widgets/workspace_content.dart';
import '../widgets/workspace_navigation.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkspaceController>();
    final section = controller.state.section;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 720;

        return Scaffold(
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (useRail) ...[
                  WorkspaceNavigation(
                    selectedIndex: section.index,
                    onSelected: controller.selectSection,
                    useRail: true,
                  ),
                  const VerticalDivider(width: 1),
                ],
                Expanded(child: WorkspaceContent(section: section)),
              ],
            ),
          ),
          bottomNavigationBar: useRail
              ? null
              : WorkspaceNavigation(
                  selectedIndex: section.index,
                  onSelected: controller.selectSection,
                ),
        );
      },
    );
  }
}
