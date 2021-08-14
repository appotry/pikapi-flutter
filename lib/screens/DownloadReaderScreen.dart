import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Storage.dart';
import 'package:pikapi/basic/enum/PagerType.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';
import 'package:pikapi/basic/Pica.dart';
import 'components/ImageReader.dart';

// 阅读下载的内容
class DownloadReaderScreen extends StatefulWidget {
  final DownloadComic comicInfo;
  final List<DownloadEp> epList;
  final int currentEpOrder;
  final int? initPictureRank;
  final PagerType pagerType = storedPagerType;

  DownloadReaderScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
    required this.currentEpOrder,
    this.initPictureRank,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadReaderScreenState();
}

class _DownloadReaderScreenState extends State<DownloadReaderScreen> {
  late DownloadEp _ep;
  late bool _fullScreen = false;
  late List<DownloadPicture> pictures = [];
  late Future _future = _load();
  int? _lastChangeRank;

  Future _load() async {
    if (widget.initPictureRank == null) {
      await pica.storeViewEp(widget.comicInfo.id, _ep.epOrder, _ep.title, 1);
    }
    pictures.clear();
    for (var ep in widget.epList) {
      if (ep.epOrder == widget.currentEpOrder) {
        pictures.addAll((await pica.downloadPicturesByEpId(ep.id)));
      }
    }
  }

  Future _onPositionChange(int position) async {
    _lastChangeRank = position + 1;
    return pica.storeViewEp(
        widget.comicInfo.id, _ep.epOrder, _ep.title, position + 1);
  }

  @override
  void initState() {
    widget.epList.forEach((element) {
      if (element.epOrder == widget.currentEpOrder) {
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
                              return DownloadReaderScreen(
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
            (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return ImageReader(
            ImageReaderStruct(
              images: pictures
                  .map((e) => ReaderImageInfo(e.fileServer, e.path, e.localPath,
                      e.width, e.height, e.format, e.fileSize))
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
    var orderMap = Map<int, DownloadEp>();
    widget.epList.forEach((element) {
      orderMap[element.epOrder] = element;
    });
    if (orderMap.containsKey(widget.currentEpOrder + 1)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadReaderScreen(
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
