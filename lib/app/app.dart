import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/doubles_scheduler/presentation/event_setup_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lanske',
      debugShowCheckedModeBanner: true,
      theme: appTheme,
      home: const EventSetupPage(),
    );
  }
}
