import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/service/pica.dart';
import 'ComicReaderScreen.dart';
import 'DownloadConfirmScreen.dart';
import 'components/ComicDescriptionCard.dart';
import 'components/ComicInfoCard.dart';
import 'components/ComicTagsCard.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';

class ComicInfoScreen extends StatefulWidget {
  final String comicId;

  const ComicInfoScreen({Key? key, required this.comicId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoScreenState();
}

class _ComicInfoScreenState extends State<ComicInfoScreen> {
  late Future<void> _future = _load();

  late ComicInfo _comicInfo;
  late List<Ep> _epList = [];

  _load() async {
    _epList.clear();
    _comicInfo = await pica.comicInfo(widget.comicId);
    var page = 0;
    late EpPage rsp;
    do {
      rsp = await pica.comicEpPage(widget.comicId, ++page);
      _epList.addAll(rsp.docs);
    } while (rsp.page < rsp.pages);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: ContentError(
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
              onRefresh: () async {
                setState(() {
                  _future = _load();
                });
              },
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(),
            body: ContentLoading(label: '加载中'),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_comicInfo.title),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DownloadConfirmScreen(
                        comicInfo: _comicInfo,
                        epList: _epList.reversed.toList(),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.download_rounded),
              ),
            ],
          ),
          body: ListView(
            children: [
              ComicInfoCard(info: _comicInfo),
              ComicTagsCard(tags: _comicInfo.tags),
              ComicDescriptionCard(description: _comicInfo.description),
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
                            builder: (context) => ComicReaderScreen(
                              comicInfo: _comicInfo,
                              epList: _epList,
                              currentEpOrder: e.order,
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
              Container(height: 5),
            ],
          ),
        );
      },
    );
  }
}
