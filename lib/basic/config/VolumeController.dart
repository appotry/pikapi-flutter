/// 音量键翻页

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Pica.dart';

const propertyName = "volumeController";

late bool volumeController;

Future<void> initVolumeController() async {
  volumeController = (await pica.loadProperty(propertyName, "false")) == "true";
}

String volumeControllerName() {
  return volumeController ? "是" : "否";
}

Future<void> chooseVolumeController(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "音量键控制翻页", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await pica.saveProperty(propertyName, "$target");
    volumeController = target;
  }
}
