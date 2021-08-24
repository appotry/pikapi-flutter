/// 列表页下一页的行为

enum PagerAction {
  CONTROLLER,
  STREAM,
}

PagerAction pagerActionFromString(String string) {
  for (var value in PagerAction.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return PagerAction.CONTROLLER;
}

Map<String, PagerAction> pagerActionMap = {
  "使用按钮": PagerAction.CONTROLLER,
  "瀑布流": PagerAction.STREAM,
};

String pagerActionName(PagerAction action) {
  for (var e in pagerActionMap.entries) {
    if (e.value == action) {
      return e.key;
    }
  }
  return '';
}
