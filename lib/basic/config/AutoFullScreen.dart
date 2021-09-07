/// 自动全屏

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Pica.dart';

late bool gAutoFullScreen;

Future<void> initAutoFullScreen() async {
  gAutoFullScreen = await pica.getAutoFullScreen();
}

String autoFullScreenName() {
  return gAutoFullScreen ? "是" : "否";
}

Future<void> chooseAutoFullScreen(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "进入阅读器自动全屏", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await pica.setAutoFullScreen(target);
    gAutoFullScreen = target;
  }
}
