enum FullScreenAction {
  CONTROLLER,
  TOUCH_ONCE,
}

FullScreenAction fullScreenActionFromString(String string) {
  for (var value in FullScreenAction.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return FullScreenAction.CONTROLLER;
}

Map<String, FullScreenAction> fullScreenActionMap = {
  "使用控制器": FullScreenAction.CONTROLLER,
  "点击屏幕一次": FullScreenAction.TOUCH_ONCE,
};

String fullScreenActionName(FullScreenAction action){
  for (var e in fullScreenActionMap.entries) {
    if (e.value == action) {
      return e.key;
    }
  }
  return '';
}
