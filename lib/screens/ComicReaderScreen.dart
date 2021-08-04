import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';

import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ImageReader.dart';
import 'components/Images.dart';

// 在线阅读漫画
class ComicReaderScreen extends StatefulWidget {
  final ComicInfo comicInfo;
  final List<Ep> epList;
  final currentEpOrder;
  final int? initPictureRank;

  const ComicReaderScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
    required this.currentEpOrder,
    this.initPictureRank,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  late Ep _ep;
  late bool _fullScreen = false;
  late Future<List<RemoteReaderImage>> _future;

  Future<List<RemoteReaderImage>> _load() async {
    if (widget.initPictureRank == null) {
      await pica.storeViewEp(widget.comicInfo.id, _ep.order, _ep.title, 1);
    }
    var _quality = await pica.loadQuality();
    List<PicaImage> list = [];
    var _needLoadPage = 0;
    late PicturePage page;
    do {
      page = await pica.comicPicturePageWithQuality(
        widget.comicInfo.id,
        widget.currentEpOrder,
        ++_needLoadPage,
        _quality,
      );
      list.addAll(page.docs.map((element) => element.media));
    } while (page.pages > page.page);
    return list
        .map((e) => RemoteReaderImage(
              fileServer: e.fileServer,
              path: e.path,
            ))
        .toList();
  }

  Future _onPositionChange(int position) async {
    return pica.storeViewEp(
        widget.comicInfo.id, _ep.order, _ep.title, position);
    // 暂时删除了+1
  }

  @override
  void initState() {
    widget.epList.forEach((element) {
      if (element.order == widget.currentEpOrder) {
        _ep = element;
      }
    });
    _future = _load();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _fullScreen
          ? null
          : AppBar(
              title: Text("${_ep.title} - ${widget.comicInfo.title}"),
            ),
      body: _buildReader(),
    );
  }

  Widget _buildReader() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context,
          AsyncSnapshot<List<RemoteReaderImage>> snapshot) {
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
        return ImageReader(
          images: snapshot.data!,
          fullScreen: _fullScreen,
          onFullScreenChange: (fullScreen) {
            setState(() {
              _fullScreen = fullScreen;
              SystemChrome.setEnabledSystemUIOverlays(
                  fullScreen ? [] : SystemUiOverlay.values);
            });
          },
          onNextEp: _next,
          onPositionChange: _onPositionChange,
          initPosition: widget.initPictureRank == null
              ? null
              : widget.initPictureRank! - 1,
        );
      },
    );
  }

  void _next() {
    var orderMap = Map<int, Ep>();
    widget.epList.forEach((element) {
      orderMap[element.order] = element;
    });
    if (orderMap.containsKey(widget.currentEpOrder + 1)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ComicReaderScreen(
            comicInfo: widget.comicInfo,
            epList: widget.epList,
            currentEpOrder: widget.currentEpOrder + 1,
          ),
        ),
      );
    } else {
      defaultToast(context, "找不到下一章啦");
    }
  }
}
