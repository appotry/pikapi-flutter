import 'dart:async';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/service/pica.dart';

import 'components/ContentLoading.dart';

class DownloadImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadImportScreenState();
}

class _DownloadImportScreenState extends State<DownloadImportScreen> {
  late StreamSubscription ls;
  String importMessage = "";
  bool importing = false;


  void _onMessageChange(event) {
    if (event is String) {
      setState(() {
        importMessage = event;
      });
    }
  }

  @override
  void initState() {
    ls = exportingEventChannel.receiveBroadcastStream().listen(_onMessageChange);
    super.initState();
  }

  @override
  void dispose() {
    ls.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (importing) {
      return Scaffold(
        body: ContentLoading(label: importMessage),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('导入'),
      ),
      body: ListView(
        children: [
          MaterialButton(
            onPressed: () async {
              late String root;
              if (Platform.isMacOS) {
                root = '/Users';
              } else if (Platform.isWindows) {
                root = '/';
              } else if (Platform.isAndroid) {
                var p = await Permission.storage.request();
                if (!p.isGranted) {
                  return;
                }
                root = '/storage/emulated/0';
              } else {
                throw 'error';
              }
              String? path = await FilesystemPicker.open(
                title: 'Open file',
                context: context,
                rootDirectory: Directory(root),
                fsType: FilesystemType.file,
                folderIconColor: Colors.teal,
                allowedExtensions: ['.zip'],
                fileTileSelectMode: FileTileSelectMode.wholeTile,
              );
              if (path != null) {
                try {
                  setState(() {
                    importing = true;
                  });
                  await pica.importComicDownload(path);
                  setState(() {
                    importMessage = "导入成功";
                  });
                } catch (e) {
                  setState(() {
                    importMessage = "导入失败 $e";
                  });
                } finally {
                  setState(() {
                    importing = false;
                  });
                }
              }
            },
            child: Text('选择zip文件'),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(importMessage),
          ),
        ],
      ),
    );
  }
}
