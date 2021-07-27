import 'package:flutter/material.dart';
import 'package:pikapi/basic/Themes.dart';
import 'package:pikapi/service/pica.dart';

import 'AccountScreen.dart';
import 'AppScreen.dart';

class InitScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  initState() {
    _init();
    super.initState();
  }

  _init() async {
    changeThemeByCode(await pica.loadTheme());
    if (await pica.preLogin()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffffced),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: new Image.asset(
          "lib/assets/init.jpg",
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
