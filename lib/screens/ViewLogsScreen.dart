import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/images/RemoteImage.dart';
import 'package:pikapi/service/pica.dart';

import 'ComicInfoScreen.dart';

class ViewLogsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ViewLogsScreenState();
}

class _ViewLogsScreenState extends State<ViewLogsScreen> {
  final _pageSize = 24;
  final _scrollPhysics = AlwaysScrollableScrollPhysics();
  final _scrollController = ScrollController();
  final _comicList = <ViewLog>[];

  var over = false;
  var needLoading = 1;
  late bool loading = false;

  @override
  initState() {
    _loadPage();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  void _handLoad() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent) {
      return;
    }
    if (loading || over) return;
    _loadPage();
  }

  _loadPage() {
    setState(() {
      loading = true;
      _loading().whenComplete(() {
        setState(() {
          loading = false;
        });
      });
    });
  }

  _loading() async {
    var page = await pica.viewLogPage(needLoading, _pageSize);
    if (page.isEmpty) {
      over = true;
    } else {
      _comicList.addAll(page);
    }
    needLoading++;
  }

  //RefreshIndicator

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: Scaffold(
        appBar: AppBar(
          title: Text('浏览记录'),
        ),
        body: ListView(
          physics: _scrollPhysics,
          controller: _scrollController,
          children: [
            Container(height: 10),
            _buildBook(),
          ],
        ),
      ),
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          _handLoad();
        }
        return true;
      },
    );
  }

  Widget _buildBook() {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var width = (min - 45) / 4;
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: _comicList
          .map((e) => InkWell(
                onTap: () {
                  _gotoInfo(e.id);
                },
                child: Card(
                  child: Container(
                    width: width,
                    child: Column(
                      children: [
                        LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return RemoteImage(
                              width: constraints.maxWidth,
                              fileServer: e.thumbFileServer,
                              path: e.thumbPath);
                        }),
                        Text(
                          e.title + '\n',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(height: 1.4),
                          strutStyle: StrutStyle(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  _gotoInfo(String comicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicInfoScreen(
          comicId: comicId,
        ),
      ),
    );
  }
}
