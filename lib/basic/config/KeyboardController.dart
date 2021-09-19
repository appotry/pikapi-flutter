/// 上下键翻页

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Pica.dart';

const propertyName = "keyboardController";

late bool keyboardController;

Future<void> initKeyboardController() async {
  keyboardController =
      (await pica.loadProperty(propertyName, "false")) == "true";
}

String keyboardControllerName() {
  return keyboardController ? "是" : "否";
}

Future<void> chooseKeyboardController(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "键盘控制翻页", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await pica.saveProperty(propertyName, "$target");
    keyboardController = target;
  }
}
