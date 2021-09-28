import 'package:flutter/material.dart';
import 'package:pikapi/basic/config/Address.dart';
import 'package:pikapi/basic/config/AndroidDisplayMode.dart';
import 'package:pikapi/basic/config/AutoClean.dart';
import 'package:pikapi/basic/config/AutoFullScreen.dart';
import 'package:pikapi/basic/config/ContentFailedReloadAction.dart';
import 'package:pikapi/basic/config/FullScreenAction.dart';
import 'package:pikapi/basic/config/FullScreenUI.dart';
import 'package:pikapi/basic/config/KeyboardController.dart';
import 'package:pikapi/basic/config/PagerAction.dart';
import 'package:pikapi/basic/config/Proxy.dart';
import 'package:pikapi/basic/config/Quality.dart';
import 'package:pikapi/basic/config/ReaderDirection.dart';
import 'package:pikapi/basic/config/ReaderType.dart';
import 'package:pikapi/basic/config/ShadowCategories.dart';
import 'package:pikapi/basic/config/Themes.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/config/ListLayout.dart';
import 'package:pikapi/basic/config/VolumeController.dart';

import 'AccountScreen.dart';
import 'AppScreen.dart';

// 初始化界面
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

  Future<dynamic> _init() async {
    // 初始化配置文件
    await autoClean();
    await initAddress();
    await initProxy();
    await initQuality();
    await initTheme();
    await initListLayout();
    await initReaderType();
    await initReaderDirection();
    await initAutoFullScreen();
    await initFullScreenAction();
    await initPagerAction();
    await initShadowCategories();
    await initFullScreenUI();
    switchFullScreenUI();
    await initContentFailedReloadAction();
    await initVolumeController();
    await initKeyboardController();
    await initAndroidDisplayMode();
    // 登录, 如果token失效重新登录, 网络不好的时候可能需要1分钟
    if (await pica.preLogin()) {
      // 如果token或username+password有效则直接进入登录好的界面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppScreen()),
      );
    } else {
      // 否则跳转到登录页
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
