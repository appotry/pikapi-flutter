import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/ItemBuilder.dart';
import 'package:pikapi/screens/components/Recommendation.dart';
import 'package:pikapi/service/pica.dart';
import 'ComicReaderScreen.dart';
import 'DownloadConfirmScreen.dart';
import 'components/ComicComment.dart';
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
  late var _tabIndex = 0;
  late Future<ComicInfo> _comicFuture = _loadComic();
  late Future<List<Ep>> _epListFuture = _loadEps();

  Future<ComicInfo> _loadComic() async {
    return await pica.comicInfo(widget.comicId);
  }

  Future<List<Ep>> _loadEps() async {
    List<Ep> eps = [];
    var page = 0;
    late EpPage rsp;
    do {
      rsp = await pica.comicEpPage(widget.comicId, ++page);
      eps.addAll(rsp.docs);
    } while (rsp.page < rsp.pages);
    return eps;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _comicFuture,
      builder: (BuildContext context, AsyncSnapshot<ComicInfo> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: ContentError(
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
              onRefresh: () async {
                setState(() {
                  _comicFuture = _loadComic();
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
        var _comicInfo = snapshot.data!;
        var theme = Theme.of(context);
        var _tabs = <Widget>[
          Tab(text: '章节 (${_comicInfo.epsCount})'),
          Tab(text: '评论 (${_comicInfo.commentsCount})'),
        ];
        var _views = <Widget>[
          _buildEpWrap(_epListFuture, _comicInfo),
          ComicComment(_comicInfo.id),
        ];

        return DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(_comicInfo.title),
              actions: [
                _buildDownloadAction(_epListFuture, _comicInfo),
              ],
            ),
            body: ListView(
              children: [
                ComicInfoCard(info: _comicInfo),
                ComicTagsCard(tags: _comicInfo.tags),
                ComicDescriptionCard(description: _comicInfo.description),
                Container(height: 5),
                Container(
                  height: 40,
                  color: theme.accentColor.withOpacity(.025),
                  child: TabBar(
                    tabs: _tabs,
                    indicatorColor: theme.accentColor,
                    labelColor: theme.accentColor,
                    onTap: (val) async => setState(() => _tabIndex = val),
                  ),
                ),
                Container(height: 15),
                IndexedStack(
                  index: _tabIndex,
                  children: _views,
                ),
                Container(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadAction(
    Future<List<Ep>> _epListFuture,
    ComicInfo _comicInfo,
  ) {
    return FutureBuilder(
      future: _epListFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Ep>> snapshot) {
        if (snapshot.hasError) {
          return IconButton(
            onPressed: () {
              setState(() {
                _epListFuture = _loadEps();
              });
            },
            icon: Icon(Icons.sync_problem),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return IconButton(onPressed: () {}, icon: Icon(Icons.sync));
        }
        var _epList = snapshot.data!;
        return IconButton(
          onPressed: () async {
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
        );
      },
    );
  }

  Widget _buildEpWrap(Future<List<Ep>> _epListFuture, ComicInfo _comicInfo) {
    return ItemBuilder(
      future: _epListFuture,
      successBuilder: (BuildContext context, AsyncSnapshot<List<Ep>> snapshot) {
        var _epList = snapshot.data!;
        return Wrap(
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
                child: Text(e.title, style: TextStyle(color: Colors.black)),
              ),
            );
          }).toList(),
        );
      },
      onRefresh: () async => setState(() => _epListFuture = _loadEps()),
    );
  }
}
