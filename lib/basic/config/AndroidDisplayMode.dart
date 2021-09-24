import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Pica.dart';

import '../Common.dart';

const _propertyName = "androidDisplayMode";

List<String> modes = [];
String _androidDisplayMode = "";

Future initAndroidDisplayMode() async {
  if (Platform.isAndroid) {
    _androidDisplayMode = await pica.loadProperty(_propertyName, "");
    modes = await pica.loadAndroidModes();
    await _changeMode();
  }
}

Future _changeMode() async {
  await pica.setAndroidMode(_androidDisplayMode);
}

String androidDisplayModeName() {
  return _androidDisplayMode;
}

Future<void> chooseAndroidDisplayMode(BuildContext context) async {
  if (Platform.isAndroid) {
    List<String> list = [""];
    list.addAll(modes);
    String? result = await chooseListDialog<String>(context, "安卓屏幕刷新率 \n(若为置空操作重启应用生效)", list);
    if (result != null) {
      await pica.saveProperty(_propertyName, "$result");
      _androidDisplayMode = result;
      await _changeMode();
    }
  }
}
