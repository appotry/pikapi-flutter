import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

double coverWidth = 210;
double coverHeight = 315;

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

Future<bool> confirmDialog(
    BuildContext context, String title, String content) async {
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
                    child: new Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  new MaterialButton(
                    child: new Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              )) ??
      false;
}

Future alertDialog(BuildContext context, String title, String content) {
  return showDialog(
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

Future<T?> chooseListDialog<T>(
  BuildContext context,
  String title,
  List<T> items,
) async {
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: items
            .map((e) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(e);
                  },
                  child: Text('$e'),
                ))
            .toList(),
      );
    },
  );
}

Future<T?> chooseMapDialog<T>(
    BuildContext buildContext, Map<String, T> values, String title) async {
  return await showDialog<T>(
    context: buildContext,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: values.entries
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

var _controller = TextEditingController.fromValue(TextEditingValue(text: ''));

Future<String?> displayTextInputDialog(
  BuildContext context,
  String title,
  String hint,
  String src,
  String desc,
) {
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
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            child: Text('确认'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
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

String formatTimeToDateTime(String str) {
  try {
    var c = DateTime.parse(str);
    return "${add0(c.year, 4)}-${add0(c.month, 2)}-${add0(c.day, 2)} ${add0(c.hour, 2)}:${add0(c.minute, 2)}";
  } catch (e) {
    return "-";
  }
}

final TextEditingController _textEditController =
    TextEditingController(text: '');

Future<String?> inputString(BuildContext context, String title,
    {String hint = ""}) async {
  _textEditController.clear();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Card(
          child: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(title),
                Container(
                  child: TextField(
                    controller: _textEditController,
                    decoration: new InputDecoration(
                      labelText: "$hint",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('取消'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context, _textEditController.text);
            },
            child: Text('确定'),
          ),
        ],
      );
    },
  );
}
