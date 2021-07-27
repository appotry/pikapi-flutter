import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/service/pica.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'DownloadImportScreen.dart';
import 'DownloadInfoScreen.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

class DownloadListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  late Future<List<DownloadComicWithLogoPath>> _f = pica.allDownloads();
  late StreamSubscription<dynamic> _sub;
  DownloadComic? downloading;

  @override
  void initState() {
    _sub = downloadingComicEventChannel
        .receiveBroadcastStream({"SCREEN": "DOWNLOAD_LIST"}).listen(
      (event) {
        print("EVENT");
        print(event);
        if (event is String) {
          try {
            setState(() {
              downloading = DownloadComic.fromJson(json.decode(event));
            });
          } catch (e, s) {
            print(e);
            print(s);
          }
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('下载列表'),
        actions: [
          MaterialButton(
              minWidth: 0,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DownloadImportScreen(),
                  ),
                );
                setState(() {
                  _f = pica.allDownloads();
                });
              },
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Icon(
                    Icons.label_important,
                    size: 18,
                    color: Colors.white,
                  ),
                  Text(
                    '导入',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Expanded(child: Container()),
                ],
              )),
          MaterialButton(
              minWidth: 0,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('下载任务'),
                      content: Text(
                        // downloader.running() ? "暂停下载吗?" : "启动下载吗?",
                        '',
                      ),
                      actions: [
                        MaterialButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text('取消'),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // if (downloader.running()) {
                            //   properties.saveDownloading(false);
                            //   setState(() {
                            //     downloader.stopService();
                            //   });
                            // } else {
                            //   properties.saveDownloading(true);
                            //   setState(() {
                            //     downloader.startService();
                            //   });
                            // }
                          },
                          child: Text('确认'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Icon(
                    Icons.schedule_send,
                    // downloader.running()
                    //     ? Icons.compare_arrows_sharp
                    //     : Icons.schedule_send,
                    size: 18,
                    color: Colors.white,
                  ),
                  Text(
                    '下载中',
                    // downloader.running()
                    //     ? '下载中'
                    //     : '暂停中',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Expanded(child: Container()),
                ],
              )),
          MaterialButton(
              minWidth: 0,
              onPressed: () async {
                await pica.resetFailed();
                setState(() {
                  _f = pica.allDownloads();
                });
                showToast("所有失败的下载已经恢复",
                    context: context,
                    position: StyledToastPosition.center,
                    animation: StyledToastAnimation.scale,
                    reverseAnimation: StyledToastAnimation.fade,
                    duration: Duration(seconds: 4),
                    animDuration: Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    reverseCurve: Curves.linear);
              },
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Icon(
                    Icons.sync_problem,
                    size: 18,
                    color: Colors.white,
                  ),
                  Text(
                    '恢复',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Expanded(child: Container()),
                ],
              )),
        ],
      ),
      body: FutureBuilder(
        future: _f,
        builder: (BuildContext context,
            AsyncSnapshot<List<DownloadComicWithLogoPath>> snapshot) {
          if (snapshot.hasError) {
            print("${snapshot.error}");
            print("${snapshot.stackTrace}");
            return Center(child: Text('加载失败'));
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }

          var data = snapshot.data!;

          if (downloading != null) {
            print("DOWNLOADING");
            print(downloading);
            try {
              for (var i = 0; i < data.length; i++) {
                if (downloading!.id == data[i].id) {
                  print("ID ID ID");
                  data[i].copy(downloading!);
                }
              }
            } catch (e, s) {
              print(e);
              print(s);
            }
          }

          return ListView(
            children: [
              ...data.map(
                (e) => Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.2,
                  secondaryActions: <Widget>[
                    ...e.deleting
                        ? []
                        : [
                            IconSlideAction(
                              caption: '删除',
                              color: Colors.red.shade500,
                              icon: Icons.delete_forever,
                              onTap: () async {
                                // await downloadDb.deleteTask(e.id);
                                // downloader.reset();
                                // setState(() => e.deleting = 1);
                              },
                            ),
                          ],
                  ],
                  child: InkWell(
                    onTap: () {
                      if (e.deleting) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DownloadInfoScreen(
                            comicId: e.id,
                            comicTitle: e.title,
                          ),
                        ),
                      );
                    },
                    child: DownloadInfoCard(
                      task: e,
                      downloading:
                          downloading != null && downloading!.id == e.id,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
