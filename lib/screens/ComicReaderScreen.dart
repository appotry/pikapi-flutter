import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/store/Categories.dart';
import 'package:pikapi/basic/config/AutoFullScreen.dart';
import 'package:pikapi/basic/config/Quality.dart';
import 'package:pikapi/basic/config/ReaderDirection.dart';
import 'package:pikapi/basic/config/ReaderType.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';
import 'components/ImageReader.dart';

// 在线阅读漫画
class ComicReaderScreen extends StatefulWidget {
  final ComicInfo comicInfo;
  final List<Ep> epList;
  final currentEpOrder;
  final int? initPictureRank;
  final ReaderType pagerType = gReaderType;
  final ReaderDirection pagerDirection = gReaderDirection;
  late final bool autoFullScreen;

  ComicReaderScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
    required this.currentEpOrder,
    this.initPictureRank,
    bool? autoFullScreen,
  }) : super(key: key) {
    this.autoFullScreen = autoFullScreen ?? gAutoFullScreen;
  }

  @override
  State<StatefulWidget> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  late Ep _ep;
  late bool _fullScreen = widget.autoFullScreen;
  late Future<List<PicaImage>> _future;
  int? _lastChangeRank;

  Future<List<PicaImage>> _load() async {
    if (widget.initPictureRank == null) {
      await pica.storeViewEp(widget.comicInfo.id, _ep.order, _ep.title, 1);
    }
    List<PicaImage> list = [];
    var _needLoadPage = 0;
    late PicturePage page;
    do {
      page = await pica.comicPicturePageWithQuality(
        widget.comicInfo.id,
        widget.currentEpOrder,
        ++_needLoadPage,
        currentQualityCode,
      );
      list.addAll(page.docs.map((element) => element.media));
    } while (page.pages > page.page);
    return list;
  }

  Future _onPositionChange(int position) async {
    _lastChangeRank = position + 1;
    return pica.storeViewEp(
        widget.comicInfo.id, _ep.order, _ep.title, position + 1);
  }

  @override
  void initState() {
    if (widget.autoFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
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
              actions: [
                IconButton(
                  onPressed: () async {
                    await choosePagerDirection(context);
                    if (widget.pagerDirection != gReaderDirection) {
                      _reloadReader();
                    }
                  },
                  icon: Icon(Icons.grid_goldenratio),
                ),
                IconButton(
                  onPressed: () async {
                    await choosePagerType(context);
                    if (widget.pagerType != gReaderType) {
                      _reloadReader();
                    }
                  },
                  icon: Icon(Icons.view_day_outlined),
                ),
              ],
            ),
      body: ContentBuilder(
        future: _future,
        onRefresh: () async {
          setState(() {
            _future = _load();
          });
        },
        successBuilder:
            (BuildContext context, AsyncSnapshot<List<PicaImage>> snapshot) {
          return ImageReader(
            snapshot.data!
                .map((e) => ReaderImageInfo(
                      e.fileServer,
                      e.path,
                      null,
                      null,
                      null,
                      null,
                      null,
                    ))
                .toList(),
            ImageReaderStruct(
              fullScreen: _fullScreen,
              onFullScreenChange: _onFullScreenChange,
              onNextEp: _next,
              onPositionChange: _onPositionChange,
              initPosition: widget.initPictureRank == null
                  ? null
                  : widget.initPictureRank! - 1,
              pagerType: widget.pagerType,
              pagerDirection: widget.pagerDirection,
            ),
          );
        },
      ),
    );
  }

  Future _onFullScreenChange(bool fullScreen) async {
    setState(() {
      SystemChrome.setEnabledSystemUIOverlays(
          fullScreen ? [] : SystemUiOverlay.values);
      _fullScreen = fullScreen;
    });
  }

  Future _next() async {
    var orderMap = Map<int, Ep>();
    widget.epList.forEach((element) {
      orderMap[element.order] = element;
    });
    if (orderMap.containsKey(widget.currentEpOrder + 1)) {
      Navigator.of(context).pop(ComicReaderScreen(
        comicInfo: widget.comicInfo,
        epList: widget.epList,
        currentEpOrder: widget.currentEpOrder + 1,
        autoFullScreen: _fullScreen,
      ));
    } else {
      defaultToast(context, "找不到下一章啦");
    }
  }

  // 重新加载本页
  void _reloadReader() {
    Navigator.of(context).pop(ComicReaderScreen(
      comicInfo: widget.comicInfo,
      epList: widget.epList,
      currentEpOrder: widget.currentEpOrder,
      initPictureRank: _lastChangeRank ?? widget.initPictureRank,
      // maybe null
      autoFullScreen: _fullScreen,
    ));
  }
}
