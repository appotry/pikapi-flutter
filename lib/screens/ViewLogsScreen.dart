
import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Pica.dart';

import 'ComicInfoScreen.dart';
import 'components/ViewLogWrap.dart';

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
  final _comicList = <ViewLogWrapEntity>[];

  var _isLoading = false; // 是否加载中
  var _scrollOvered = false; // 滚动到最后
  var _offset = 0;

  Future _clearAll() async {
    if (await confirmDialog(
      context,
      "您要清除所有浏览记录吗? ",
      "将会同时删除浏览进度!",
    )) {
      await pica.clearAllViewLog();
      setState(() {
        _comicList.clear();
        _isLoading = false;
        _scrollOvered = true;
        _offset = 0;
      });
    }
  }

  Future _clearOnce(String id) async {
    if (await confirmDialog(
      context,
      "您要清除这条浏览记录吗? ",
      "将会同时删除浏览进度!",
    )) {
      await pica.deleteViewLog(id);
      setState(() {
        for (var i = 0; i < _comicList.length; i++) {
          if (_comicList[i].id == id) {
            _comicList[i] = ViewLogWrapEntity(
              _comicList[i].id,
              _comicList[i].title,
              _comicList[i].fileServer,
              _comicList[i].path,
              deleted: true,
            );
            break;
          }
        }
      });
    }
  }

  // 加载一页
  Future<dynamic> _loadPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var page = await pica.viewLogPage(_offset, _pageSize);
      if (page.isEmpty) {
        _scrollOvered = true;
      } else {
        _comicList.addAll(page.map((e) =>
            ViewLogWrapEntity(e.id, e.title, e.thumbFileServer, e.thumbPath)));
      }
      _offset += _pageSize;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 滚动事件
  void _handScroll() {
    if (_scrollController.position.pixels +
            MediaQuery.of(context).size.height / 2 <
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
          actions: [
            IconButton(onPressed: _clearAll, icon: Icon(Icons.auto_delete)),
          ],
        ),
        body: ListView(
          physics: _scrollPhysics,
          controller: _scrollController,
          children: [
            Container(height: 10),
            ViewLogWrap(
              onTapComic: _chooseComic,
              comics: _comicList,
              onDelete: _clearOnce,
            ),
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
