import 'package:flutter/cupertino.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

String categoryTitle(String? categoryTitle) {
  return categoryTitle ?? "全分类";
}

void defaultToast(BuildContext context, String title) {
  showToast(
    title,
    context: context,
    position: StyledToastPosition.center,
    animation: StyledToastAnimation.scale,
    reverseAnimation: StyledToastAnimation.fade,
    duration: Duration(seconds: 4),
    animDuration: Duration(seconds: 1),
    curve: Curves.elasticOut,
    reverseCurve: Curves.linear,
  );
}


String add0(int num, int len) {
  var rsp = "$num";
  while (rsp.length < len) {
    rsp = "0$rsp";
  }
  return rsp;
}

String formatTime(String str) {
  try {
    var c = DateTime.parse(str);
    return "${add0(c.year, 4)}-${add0(c.month, 2)}-${add0(c.day, 2)}";
  } catch (e) {
    return "-";
  }
}
