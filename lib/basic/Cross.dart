import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Pica.dart';


void copyToClipBoard(BuildContext context, String string) {
  if (Platform.isWindows || Platform.isMacOS) {
    FlutterClipboard.copy(string);
    defaultToast(context, "已复制到剪切板");
  } else if (Platform.isAndroid) {
    FlutterClipboard.copy(string);
    defaultToast(context, "已复制到剪切板");
  }
}

Future<dynamic> openUrl(String url) async {
  if (Platform.isAndroid || Platform.isIOS) {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
      );
    }
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await pica.open(url);
  }
}
