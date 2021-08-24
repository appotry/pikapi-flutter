/// 阅读器的类型

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ReaderType {
  WEB_TOON,
  WEB_TOON_ZOOM,
  GALLERY,
}

var types = {
  'WebToon (默认)': ReaderType.WEB_TOON,
  'WebToon + 双击放大': ReaderType.WEB_TOON_ZOOM,
  '相册': ReaderType.GALLERY,
};

ReaderType pagerTypeFromString(String pagerTypeString) {
  for (var value in ReaderType.values) {
    if (pagerTypeString == value.toString()) {
      return value;
    }
  }
  return ReaderType.WEB_TOON;
}

String readerTypeName(ReaderType pagerType) {
  for (var e in types.entries) {
    if (e.value == pagerType) {
      return e.key;
    }
  }
  return '';
}

Future<ReaderType?> choosePagerType(BuildContext buildContext) async {
  return await showDialog<ReaderType>(
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
