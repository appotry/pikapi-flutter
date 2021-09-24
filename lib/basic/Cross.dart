/// 与平台交互的操作

import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Pica.dart';

/// 复制内容到剪切板
void copyToClipBoard(BuildContext context, String string) {
  if (Platform.isWindows || Platform.isMacOS) {
    FlutterClipboard.copy(string);
    defaultToast(context, "已复制到剪切板");
  } else if (Platform.isAndroid) {
    FlutterClipboard.copy(string);
    defaultToast(context, "已复制到剪切板");
  }
}

/// 打开web页面
Future<dynamic> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
    );
  }
}

/// 保存图片
Future<dynamic> saveImage(String path, BuildContext context) async {
  Future? future;
  if (Platform.isIOS) {
    future = pica.iosSaveFileToImage(path);
  } else if (Platform.isAndroid) {
    future = _saveImageAndroid(path, context);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    String? folder = await chooseFolder(context);
    if (folder != null) {
      future = pica.convertImageToJPEG100(path, folder);
    }
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

/// 选择一个文件夹用于保存文件
Future<String?> chooseFolder(BuildContext context) async {
  late String root;
  if (Platform.isWindows) {
    root = '/';
  } else if (Platform.isMacOS) {
    root = '/Users';
  } else if (Platform.isLinux) {
    root = '/';
  } else if (Platform.isAndroid) {
    var p = await Permission.storage.request();
    if (!p.isGranted) {
      return null;
    }
    root = '/storage/emulated/0';
  } else {
    throw 'error';
  }
  return FilesystemPicker.open(
    title: '选择一个文件夹',
    pickText: '将文件保存到这里',
    context: context,
    fsType: FilesystemType.folder,
    rootDirectory: Directory(root),
  );
}

void confirmCopy(BuildContext context, String content) async {
  if (await confirmDialog(context, "复制", content)) {
    copyToClipBoard(context, content);
  }
}
