import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

Future<bool> confirmDialog(BuildContext context, String title, String content) async {
  return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(title),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text(content),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new MaterialButton(
                    child: new Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  new MaterialButton(
                    child: new Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              )) ??
      false;
}

void alertDialog(BuildContext context, String title, String content) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(content),
                ],
              ),
            ),
            actions: <Widget>[
              new MaterialButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
}

var _controller = TextEditingController.fromValue(TextEditingValue(text: ''));

Future<void> displayTextInputDialog(
  BuildContext context,
  String title,
  String hint,
  String src,
  String desc,
  void Function(String) onConfirm,
) async {
  _controller.text = src;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: hint),
              ),
              desc.isEmpty
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        desc,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.color
                                ?.withOpacity(.5)),
                      ),
                    ),
            ],
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          MaterialButton(
            child: Text('确认'),
            onPressed: () {
              onConfirm(_controller.text);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

String add0(int num, int len) {
  var rsp = "$num";
  while (rsp.length < len) {
    rsp = "0$rsp";
  }
  return rsp;
}

String formatTimeToDate(String str) {
  try {
    var c = DateTime.parse(str);
    return "${add0(c.year, 4)}-${add0(c.month, 2)}-${add0(c.day, 2)}";
  } catch (e) {
    return "-";
  }
}
