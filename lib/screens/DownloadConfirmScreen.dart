import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/ContentLoading.dart';
import 'package:pikapi/service/pica.dart';

import 'components/ComicInfoCard.dart';

class DownloadConfirmScreen extends StatefulWidget {
  final ComicInfo comicInfo;
  final List<Ep> epList;

  const DownloadConfirmScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadConfirmScreenState();
}

class _DownloadConfirmScreenState extends State<DownloadConfirmScreen> {
  DownloadComic? task;
  List<int> taskedEps = [];
  List<int> selectedEps = [];
  late Future f = _load();

  _load() async {
    taskedEps.clear();
    task = await pica.loadDownloadComic(widget.comicInfo.id);
    if (task != null) {
      var epList = await pica.downloadEpList(widget.comicInfo.id);
      taskedEps.addAll(epList.map((e) => e.epOrder));
    }
  }

  _selectAll() async {
    setState(() {
      selectedEps.clear();
      widget.epList.forEach((element) {
        if (!taskedEps.contains(element.order)) {
          selectedEps.add(element.order);
        }
      });
    });
  }

  _download() async {
    if (selectedEps.isEmpty) {
      return;
    }

    var create = DownloadComic(
      widget.comicInfo.id,
      widget.comicInfo.createdAt,
      widget.comicInfo.updatedAt,
      widget.comicInfo.title,
      widget.comicInfo.author,
      widget.comicInfo.pagesCount,
      widget.comicInfo.epsCount,
      widget.comicInfo.finished,
      json.encode(widget.comicInfo.categories),
      widget.comicInfo.thumb.originalName,
      widget.comicInfo.thumb.fileServer,
      widget.comicInfo.thumb.path,
      widget.comicInfo.description,
      widget.comicInfo.chineseTeam,
      json.encode(widget.comicInfo.tags),
    );
    List<DownloadEp> list = [];
    widget.epList.forEach((element) {
      if (selectedEps.contains(element.order)) {
        list.add(DownloadEp(
          widget.comicInfo.id,
          element.id,
          element.updatedAt,
          element.order,
          element.title,
        ));
      }
    });
    if (task != null) {
      await pica.addDownload(create, list);
    } else {
      await pica.createDownload(create, list);
    }
    Navigator.pop(context);
  }

  Color _colorOfEp(Ep e) {
    if (taskedEps.contains(e.order)) {
      return Colors.grey.shade300;
    }
    if (selectedEps.contains(e.order)) {
      return Colors.blueGrey.shade300;
    }
    return Colors.grey.shade200;
  }

  Icon _iconOfEp(Ep e) {
    if (taskedEps.contains(e.order)) {
      return Icon(Icons.download_rounded, color: Colors.black);
    }
    if (selectedEps.contains(e.order)) {
      return Icon(Icons.check_box, color: Colors.black);
    }
    return Icon(Icons.check_box_outline_blank, color: Colors.black);
  }

  void _clickOfEp(Ep e) {
    if (taskedEps.contains(e.order)) {
      return;
    }
    if (selectedEps.contains(e.order)) {
      setState(() {
        selectedEps.remove(e.order);
      });
    } else {
      setState(() {
        selectedEps.add(e.order);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("下载 - ${widget.comicInfo.title}"),
      ),
      body: FutureBuilder(
        future: f,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            print(snapshot.stackTrace);
            return Text('error');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }
          return ListView(
            children: [
              ComicInfoCard(info: widget.comicInfo),
              _buildButtons(),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                runSpacing: 10,
                spacing: 10,
                children: [
                  ...widget.epList.map((e) {
                    return Container(
                      padding: EdgeInsets.all(5),
                      child: MaterialButton(
                        onPressed: () {
                          _clickOfEp(e);
                        },
                        color: _colorOfEp(e),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _iconOfEp(e),
                            Container(
                              width: 10,
                            ),
                            Text(e.title,
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
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

  Widget _buildButtons() {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceAround,
        children: [
          MaterialButton(
            color: theme.accentColor,
            textColor: Colors.white,
            onPressed: _selectAll,
            child: Text('全选'),
          ),
          MaterialButton(
            color: theme.accentColor,
            textColor: Colors.white,
            onPressed: _download,
            child: Text('确定下载'),
          ),
        ],
      ),
    );
  }
}
