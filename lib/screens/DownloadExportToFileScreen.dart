import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Cross.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/screens/DownloadExportToSocketScreen.dart';

import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

// 导出
class DownloadExportToFileScreen extends StatefulWidget {
  final String comicId;
  final String comicTitle;

  DownloadExportToFileScreen({
    required this.comicId,
    required this.comicTitle,
  });

  @override
  State<StatefulWidget> createState() => _DownloadExportToFileScreenState();
}

class _DownloadExportToFileScreenState
    extends State<DownloadExportToFileScreen> {
  late DownloadComic _task;
  late Future _future = _load();
  late bool exporting = false;
  late String exportMessage = "导出中";
  late String exportResult = "";

  Future _load() async {
    _task = (await pica.loadDownloadComic(widget.comicId))!;
  }

  @override
  void initState() {
    registerEvent(_onMessageChange, "EXPORT");
    super.initState();
  }

  @override
  void dispose() {
    unregisterEvent(_onMessageChange);
    super.dispose();
  }

  void _onMessageChange(event) {
    setState(() {
      exportMessage = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (exporting) {
      return Scaffold(
        body: ContentLoading(label: exportMessage),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("导出 - " + widget.comicTitle),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = _load();
                  });
                });
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }
          return ListView(
            children: [
              DownloadInfoCard(task: _task),
              Container(
                padding: EdgeInsets.all(8),
                child: exportResult != "" ? Text(exportResult) : Container(),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Text('TIPS : 选择一个目录'),
              ),
              _buildExportToFileButton(),
              MaterialButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DownloadExportToSocketScreen(
                        task: _task,
                        comicId: widget.comicId,
                        comicTitle: widget.comicTitle,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text('传输到其他设备'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExportToFileButton() {
    if (Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isAndroid) {
      return MaterialButton(
        onPressed: () async {
          String? path = await chooseFolder(context);
          print("path $path");
          if (path != null) {
            try {
              setState(() {
                exporting = true;
              });
              await pica.exportComicDownload(
                widget.comicId,
                path,
              );
              setState(() {
                exportResult = "导出成功";
              });
            } catch (e) {
              setState(() {
                exportResult = "导出失败 $e";
              });
            } finally {
              setState(() {
                exporting = false;
              });
            }
          }
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: Text('选择导出位置'),
        ),
      );
    }
    return MaterialButton(
      onPressed: () async {},
      child: Container(
        padding: EdgeInsets.all(20),
        child: Text('IOS暂不支持导出到文件'),
      ),
    );
  }
}
