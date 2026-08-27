import 'package:flutter/material.dart';
import 'home.dart';
import 'theme.dart';

class RegaloApp extends StatelessWidget {
  const RegaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Regalo Ideal',
      theme: appTheme,
      home: const MainScreen(),
    );
  }
}