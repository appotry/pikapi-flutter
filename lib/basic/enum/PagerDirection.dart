import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum PagerDirection {
  TOP_TO_BOTTOM,
  LEFT_TO_RIGHT,
}

var types = {
  '从上到下': PagerDirection.TOP_TO_BOTTOM,
  '从左到右': PagerDirection.LEFT_TO_RIGHT,
};

PagerDirection pagerDirectionFromString(String pagerDirectionString) {
  for (var value in PagerDirection.values) {
    if (pagerDirectionString == value.toString()) {
      return value;
    }
  }
  return PagerDirection.TOP_TO_BOTTOM;
}

String pagerDirectionName(PagerDirection pagerDirection) {
  for (var e in types.entries) {
    if (e.value == pagerDirection) {
      return e.key;
    }
  }
  return '';
}

Future<PagerDirection?> choosePagerDirection(BuildContext buildContext) async {
  return await showDialog<PagerDirection>(
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
