import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PagerType {
  WEB_TOON,
  WEB_TOON_ZOOM,
  WEB_TOON_PAGE,
}

var types = {
  'WebToon (默认)': PagerType.WEB_TOON,
  'WebToon + 双指放大 (试验性)': PagerType.WEB_TOON_ZOOM,
  'WebToon + 分页 + 双击放大 (试验性)': PagerType.WEB_TOON_PAGE,
};

PagerType pagerTypeFromString(String pagerType) {
  for (var value in PagerType.values) {
    if (pagerType == value.toString()) {
      return value;
    }
  }
  return PagerType.WEB_TOON;
}

String pagerTypeName(PagerType pagerType) {
  for (var e in types.entries) {
    if (e.value == pagerType) {
      return e.key;
    }
  }
  return '';
}

Future<PagerType?> choosePagerType(BuildContext buildContext) async {
  return await showDialog<PagerType>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("选择阅读模式"),
        children: types.entries
            .map((e) => SimpleDialogOption(
                  child: Text(e.key),
                  onPressed: () {
                    Navigator.of(context).pop(e.value);
                  },
                ))
            .toList(),
      );
    },
  );
}
