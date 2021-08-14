import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/Storage.dart';
import 'package:pikapi/basic/enum/PagerType.dart';
import 'package:pikapi/screens/DownloadReaderScreen.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';

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
  final PagerType pagerType = storedPagerType;

  ComicReaderScreen({
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
  late Future<List<PicaImage>> _future;
  int? _lastChangeRank;

  Future<List<PicaImage>> _load() async {
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
    return list;
  }

  Future _onPositionChange(int position) async {
    _lastChangeRank = position + 1;
    return pica.storeViewEp(
        widget.comicInfo.id, _ep.order, _ep.title, position + 1);
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
              actions: [
                IconButton(
                  onPressed: () async {
                    PagerType? t = await choosePagerType(context);
                    if (t != null) {
                      if (widget.pagerType != t) {
                        pica.savePagerType(t);
                        storedPagerType = t;
                        // 重新加载本页
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return ComicReaderScreen(
                                comicInfo: widget.comicInfo,
                                epList: widget.epList,
                                currentEpOrder: widget.currentEpOrder,
                                initPictureRank: _lastChangeRank ??
                                    widget.initPictureRank, // maybe null
                              );
                            },
                          ),
                        );
                      }
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
            ImageReaderStruct(
              images: snapshot.data!
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
              fullScreen: _fullScreen,
              onFullScreenChange: _onFullScreenChange,
              onNextEp: _next,
              onPositionChange: _onPositionChange,
              initPosition: widget.initPictureRank == null
                  ? null
                  : widget.initPictureRank! - 1,
            ),
            widget.pagerType,
          );
        },
      ),
    );
  }

  void _onFullScreenChange(bool fullScreen) {
    setState(() {
      _fullScreen = fullScreen;
      SystemChrome.setEnabledSystemUIOverlays(
          fullScreen ? [] : SystemUiOverlay.values);
    });
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
