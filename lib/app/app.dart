import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lanske',
      theme: appTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Lanske'),
        ),
      ),
    );
  }
}
