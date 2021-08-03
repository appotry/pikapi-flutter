import 'dart:async';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Pica.dart';

import 'components/ContentLoading.dart';

// 导入
class DownloadImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadImportScreenState();
}

class _DownloadImportScreenState extends State<DownloadImportScreen> {
  bool _importing = false;
  String _importMessage = "";
  late StreamSubscription _listen;

  @override
  void initState() {
    _listen = eventChannel.receiveBroadcastStream(
        {"function": "EXPORT", "id": "DEFAULT"}).listen(_onMessageChange);
    super.initState();
  }

  @override
  void dispose() {
    _listen.cancel();
    super.dispose();
  }

  void _onMessageChange(event) {
    if (event is String) {
      setState(() {
        _importMessage = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_importing) {
      return Scaffold(
        body: ContentLoading(label: _importMessage),
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
                    _importing = true;
                  });
                  await pica.importComicDownload(path);
                  setState(() {
                    _importMessage = "导入成功";
                  });
                } catch (e) {
                  setState(() {
                    _importMessage = "导入失败 $e";
                  });
                } finally {
                  setState(() {
                    _importing = false;
                  });
                }
              }
            },
            child: Text('选择zip文件'),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(_importMessage),
          ),
        ],
      ),
    );
  }
}
