import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
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

Future<dynamic> saveImage(String path, BuildContext context) async {
  Future? future;
  if (Platform.isIOS) {
    future = pica.iosSaveFileToImage(path);
  } else {
    future = _saveImageAndroid(path, context);
  }
  if (future != null) {
    try {
      await future;
      defaultToast(context, '保存成功');
    } catch (e, s) {
      print("$e\n$s");
      defaultToast(context, '保存失败');
    }
  } else {
    defaultToast(context, '暂不支持该平台');
  }
}

Future<dynamic> _saveImageAndroid(String path, BuildContext context) async {
 var p = await Permission.storage.request();
 if (!p.isGranted) {
   return;
 }
 return pica.androidSaveFileToImage(path);
}
