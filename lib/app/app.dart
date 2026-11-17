import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/text_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/workspace/controllers/workspace_controller.dart';
import '../features/workspace/screens/workspace_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkspaceController(),
      child: MaterialApp(
        title: TextConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const WorkspaceScreen(),
      ),
    );
  }
}
