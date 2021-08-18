import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Navigatior.dart';
import 'package:pikapi/basic/Pica.dart';
import 'ComicInfoScreen.dart';
import 'DownloadExportScreen.dart';
import 'DownloadReaderScreen.dart';
import 'components/ComicDescriptionCard.dart';
import 'components/ComicTagsCard.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ContinueReadButton.dart';
import 'components/DownloadInfoCard.dart';

// 下载详情
class DownloadInfoScreen extends StatefulWidget {
  final String comicId;
  final String comicTitle;

  DownloadInfoScreen({
    required this.comicId,
    required this.comicTitle,
  });

  @override
  State<StatefulWidget> createState() => _DownloadInfoScreenState();
}

class _DownloadInfoScreenState extends State<DownloadInfoScreen> {
  late Future<ViewLog?> _viewFuture = pica.loadView(widget.comicId);
  late DownloadComic _task;
  late List<DownloadEp> _epList = [];
  late Future _future = _load();

  Future _load() async {
    _task = (await pica.loadDownloadComic(widget.comicId))!;
    _epList = await pica.downloadEpList(widget.comicId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comicTitle),
        actions: [
          ...(Platform.isWindows ||
                  Platform.isMacOS ||
                  Platform.isLinux ||
                  Platform.isAndroid)
              ? [
                  IconButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DownloadExportScreen(
                            comicId: widget.comicId,
                            comicTitle: widget.comicTitle,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add_to_home_screen),
                  ),
                ]
              : [],
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComicInfoScreen(
                    comicId: widget.comicId,
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings_ethernet_outlined),
          ),
        ],
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
          List<dynamic> tagsDynamic = json.decode(_task.tags);
          List<String> tags = tagsDynamic.map((e) => "$e").toList();
          return ListView(
            children: [
              DownloadInfoCard(task: _task),
              ComicTagsCard(tags),
              ComicDescriptionCard(description: _task.description),
              Container(height: 5),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceAround,
                children: [
                  ContinueReadButton(
                    viewFuture: _viewFuture,
                    onChoose: (int? epOrder, int? pictureRank) {
                      if (epOrder != null && pictureRank != null) {
                        for (var i in _epList) {
                          if (i.epOrder == epOrder) {
                            _push(_task, _epList, epOrder, pictureRank);
                            return;
                          }
                        }
                      } else {
                        _push(_task, _epList, _epList.first.epOrder, null);
                      }
                    },
                  ),
                  ..._epList.map((e) {
                    return Container(
                      child: MaterialButton(
                        onPressed: () {
                          _push(_task, _epList, e.epOrder, null);
                        },
                        color: Colors.white,
                        child: Text(e.title,
                            style: TextStyle(color: Colors.black)),
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _push(
    DownloadComic task,
    List<DownloadEp> epList,
    int epOrder,
    int? rank,
  ) {
    var readerScreen = DownloadReaderScreen(
      comicInfo: _task,
      epList: _epList,
      currentEpOrder: epOrder,
      initPictureRank: rank,
    );
    circularPush(context, readerScreen).whenComplete(() {
      setState(() {
        _viewFuture = pica.loadView(widget.comicId);
      });
    });
  }
}
