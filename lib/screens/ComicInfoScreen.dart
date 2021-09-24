import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Cross.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/ComicsScreen.dart';
import 'package:pikapi/basic/Navigatior.dart';
import 'package:pikapi/screens/components/ItemBuilder.dart';
import 'package:pikapi/basic/Pica.dart';
import 'ComicReaderScreen.dart';
import 'DownloadConfirmScreen.dart';
import 'components/ComicCommentList.dart';
import 'components/ComicDescriptionCard.dart';
import 'components/ComicInfoCard.dart';
import 'components/ComicTagsCard.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ContinueReadButton.dart';

// 漫画详情
class ComicInfoScreen extends StatefulWidget {
  final String comicId;

  const ComicInfoScreen({Key? key, required this.comicId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoScreenState();
}

class _ComicInfoScreenState extends State<ComicInfoScreen> with RouteAware {
  late var _tabIndex = 0;
  late Future<ComicInfo> _comicFuture = _loadComic();
  late Future<ViewLog?> _viewFuture = _loadViewLog();
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

  Future<ViewLog?> _loadViewLog() {
    return pica.loadView(widget.comicId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    setState(() {
      _viewFuture = _loadViewLog();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
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
          ComicCommentList(_comicInfo.id),
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
                ComicInfoCard(_comicInfo, linkItem: true),
                ComicTagsCard(_comicInfo.tags),
                ComicDescriptionCard(description: _comicInfo.description),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                      ),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text.rich(TextSpan(
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                if (_comicInfo.creator.id != "") {
                                  navPushOrReplace(
                                    context,
                                    (context) => ComicsScreen(
                                      creatorId: _comicInfo.creator.id,
                                      creatorName: _comicInfo.creator.name,
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                confirmCopy(
                                  context,
                                  "${_comicInfo.creator.name}",
                                );
                              },
                              child: Text(
                                "${_comicInfo.creator.name}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: "  ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text:
                                "( ${formatTimeToDate(_comicInfo.updatedAt)} )",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )),
                      Text.rich(
                        TextSpan(
                          text: "${_comicInfo.chineseTeam}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (_comicInfo.chineseTeam != "") {
                                navPushOrReplace(
                                  context,
                                  (context) => ComicsScreen(
                                    chineseTeam: _comicInfo.chineseTeam,
                                  ),
                                );
                              }
                            },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 5),
                Container(
                  height: 40,
                  color: theme.colorScheme.secondary.withOpacity(.025),
                  child: TabBar(
                    tabs: _tabs,
                    indicatorColor: theme.colorScheme.secondary,
                    labelColor: theme.colorScheme.secondary,
                    onTap: (val) async {
                      setState(() {
                        _tabIndex = val;
                      });
                    },
                  ),
                ),
                Container(height: 15),
                _views[_tabIndex],
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
        return Column(
          children: [
            ContinueReadButton(
              viewFuture: _viewFuture,
              onChoose: (int? epOrder, int? pictureRank) {
                if (epOrder != null && pictureRank != null) {
                  for (var i in _epList) {
                    if (i.order == epOrder) {
                      _push(_comicInfo, _epList, epOrder, pictureRank);
                      return;
                    }
                  }
                } else {
                  _push(
                      _comicInfo, _epList, _epList.reversed.first.order, null);
                  return;
                }
              },
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.spaceAround,
              children: [
                ..._epList.map((e) {
                  return Container(
                    child: MaterialButton(
                      onPressed: () {
                        _push(_comicInfo, _epList, e.order, null);
                      },
                      color: Colors.white,
                      child:
                          Text(e.title, style: TextStyle(color: Colors.black)),
                    ),
                  );
                }),
              ],
            ),
          ],
        );
      },
      onRefresh: () async {
        setState(() {
          _epListFuture = _loadEps();
        });
      },
    );
  }

  void _push(ComicInfo comicInfo, List<Ep> epList, int order, int? rank) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReaderScreen(
          comicInfo: comicInfo,
          epList: epList,
          currentEpOrder: order,
          initPictureRank: rank,
        ),
      ),
    );
  }
}
