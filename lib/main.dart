import 'package:flutter/material.dart';
import 'package:pikapi/screens/InitScreen.dart';
import 'package:pikapi/screens/common/Navigatior.dart';

import 'basic/Themes.dart';

void main() {
  runApp(PikachuApp());
}

class PikachuApp extends StatefulWidget {
  const PikachuApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PikachuAppState();
}

class _PikachuAppState extends State<PikachuApp> {
  ThemeData? _themeData;

  @override
  void initState() {
    themeEvent.subscribe(_onChangeTheme);
    super.initState();
  }

  @override
  void dispose() {
    themeEvent.unsubscribe(_onChangeTheme);
    super.dispose();
  }

  void _onChangeTheme(ThemeEventArgs? args) {
    setState(() {
      _themeData = args?.themeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themeData,
      navigatorObservers: [navigatorObserver],
      home: InitScreen(),
    );
  }
}
