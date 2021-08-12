import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PagerType {
  WEB_TOON,
  PAGE_WEB_TOON,
}

PagerType pagerTypeFromString(String pagerType) {
  for (var value in PagerType.values) {
    if (pagerType == value.toString()) {
      return value;
    }
  }
  return PagerType.WEB_TOON;
}

String pagerTypeName(PagerType pagerType) {
  switch (pagerType) {
    case PagerType.WEB_TOON:
      return 'WebToon';
    case PagerType.PAGE_WEB_TOON:
      return 'WebToon (分页/缩放) (试验性双击放大)';
  }
}

Future<PagerType?> choosePagerType(BuildContext buildContext) async {
  return await showDialog<PagerType>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("选择阅读模式"),
        children: [
          SimpleDialogOption(
            child: Text("WebToon"),
            onPressed: () {
              Navigator.of(context).pop(PagerType.WEB_TOON);
            },
          ),
          SimpleDialogOption(
            child: Text("WebToon (分页/缩放)"),
            onPressed: () {
              Navigator.of(context).pop(PagerType.PAGE_WEB_TOON);
            },
          ),
        ],
      );
    },
  );
}
