/// 阅读器的方向

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ReaderDirection {
  TOP_TO_BOTTOM,
  LEFT_TO_RIGHT,
}

var types = {
  '从上到下': ReaderDirection.TOP_TO_BOTTOM,
  '从左到右': ReaderDirection.LEFT_TO_RIGHT,
};

ReaderDirection pagerDirectionFromString(String pagerDirectionString) {
  for (var value in ReaderDirection.values) {
    if (pagerDirectionString == value.toString()) {
      return value;
    }
  }
  return ReaderDirection.TOP_TO_BOTTOM;
}

String readerDirectionName(ReaderDirection pagerDirection) {
  for (var e in types.entries) {
    if (e.value == pagerDirection) {
      return e.key;
    }
  }
  return '';
}

Future<ReaderDirection?> choosePagerDirection(BuildContext buildContext) async {
  return await showDialog<ReaderDirection>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("选择翻页方向"),
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
