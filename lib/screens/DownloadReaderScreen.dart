import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pikapi/screens/components/images/ReaderImage.dart';
import 'package:pikapi/service/pica.dart';

import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/ImageReader.dart';

class DownloadReaderScreen extends StatefulWidget {
  final DownloadComic comicInfo;
  final List<DownloadEp> epList;
  final int currentEpOrder;

  const DownloadReaderScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
    required this.currentEpOrder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadReaderScreenState();
}

class _DownloadReaderScreenState extends State<DownloadReaderScreen> {
  late bool _fullScreen = false;
  late List<DownloadPicture> pictures = [];
  late List<Widget> images = [];
  late Future _future = _load();

  Future _load() async {
    pictures.clear();
    images.clear();
    for (var ep in widget.epList) {
      if (ep.epOrder == widget.currentEpOrder) {
        pictures.addAll((await pica.downloadPicturesByEpId(ep.id)));
      }
    }
    images.addAll(await _buildImages(pictures));
  }

  Future<List<Widget>> _buildImages(List<DownloadPicture> pictures) async {
    return pictures.map((e) => DownloadReaderImage(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _fullScreen
          ? null
          : AppBar(
              title: Text("${_epName()} - ${widget.comicInfo.title}"),
            ),
      body: _buildReader(),
    );
  }

  Widget _buildReader() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
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
          images: images,
          fullScreen: _fullScreen,
          onFullScreenChange: (fullScreen) {
            setState(() {
              _fullScreen = fullScreen;
            });
          },
          onNextEp: _next,
        );
      },
    );
  }

  _epName() {
    var map = Map<int, DownloadEp>();
    widget.epList.forEach((element) {
      map[element.epOrder] = element;
    });
    DownloadEp? ep = map[widget.currentEpOrder];
    if (ep != null) {
      return ep.title;
    }
    return "";
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
      showToast("找不到下一章啦",
          context: context,
          position: StyledToastPosition.center,
          animation: StyledToastAnimation.scale,
          reverseAnimation: StyledToastAnimation.fade,
          duration: Duration(seconds: 4),
          animDuration: Duration(seconds: 1),
          curve: Curves.elasticOut,
          reverseCurve: Curves.linear);
    }
  }
}
