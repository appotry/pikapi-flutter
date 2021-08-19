/// 分流地址

// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"

import 'package:flutter/material.dart';

class _Address {
  final String code;
  final String label;

  _Address.of({
    required this.code,
    required this.label,
  });
}

final addressList = [
  _Address.of(code: "", label: "不分流"),
  _Address.of(code: "172.67.7.24:443", label: "分流1"),
  _Address.of(code: "104.20.180.50:443", label: "分流2"),
  _Address.of(code: "172.67.208.169:443", label: "分流3"),
];

String addressName(String address) {
  for (var value in addressList) {
    if (value.code == address) {
      return value.label;
    }
  }
  return address;
}

Future<String?> chooseAddress(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text('选择分流'),
        children: <Widget>[
          ...addressList.map(
            (e) => SimpleDialogOption(
              child: Text(e.label),
              onPressed: () {
                Navigator.of(context).pop(e.code);
              },
            ),
          ),
        ],
      );
    },
  );
}
