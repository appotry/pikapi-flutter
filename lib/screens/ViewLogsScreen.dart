import 'package:flutter/material.dart';
import 'package:pikapi/basic/Pica.dart';

import 'ComicInfoScreen.dart';
import 'components/ComicWrap.dart';

// 浏览记录
class ViewLogsScreen extends StatefulWidget {
  const ViewLogsScreen();

  @override
  State<StatefulWidget> createState() => _ViewLogsScreenState();
}

class _ViewLogsScreenState extends State<ViewLogsScreen> {
  static const _pageSize = 24;
  static const _scrollPhysics = AlwaysScrollableScrollPhysics(); // 即使不足一页仍可滚动

  final _scrollController = ScrollController();
  final _comicList = <ComicWrapEntity>[];

  var _isLoading = false; // 是否加载中
  var _scrollOvered = false; // 滚动到最后
  var _needLoadingPage = 1; // 加载到了第几页

  // 加载一页
  Future<dynamic> _loadPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var page = await pica.viewLogPage(_needLoadingPage, _pageSize);
      if (page.isEmpty) {
        _scrollOvered = true;
      } else {
        _comicList.addAll(page.map((e) =>
            ComicWrapEntity(e.id, e.title, e.thumbFileServer, e.thumbPath)));
      }
      _needLoadingPage++;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 滚动事件
  void _handScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent) {
      return;
    }
    if (_isLoading || _scrollOvered) return;
    _loadPage();
  }

  @override
  void initState() {
    _loadPage();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            ComicWrap(onTapComic: _chooseComic, comics: _comicList),
          ],
        ),
      ),
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          _handScroll();
        }
        return true;
      },
    );
  }

  void _chooseComic(String comicId) {
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
