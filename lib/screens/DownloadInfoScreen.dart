import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/service/pica.dart';
import 'ComicInfoScreen.dart';
import 'DownloadExportScreen.dart';
import 'DownloadReaderScreen.dart';
import 'components/ComicDescriptionCard.dart';
import 'components/ComicTagsCard.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

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
              ComicTagsCard(tags: tags),
              ComicDescriptionCard(description: _task.description),
              Container(height: 5),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceAround,
                children: _epList.map((e) {
                  return Container(
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadReaderScreen(
                              comicInfo: _task,
                              epList: _epList,
                              currentEpOrder: e.epOrder,
                            ),
                          ),
                        );
                      },
                      color: Colors.white,
                      child:
                          Text(e.title, style: TextStyle(color: Colors.black)),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
