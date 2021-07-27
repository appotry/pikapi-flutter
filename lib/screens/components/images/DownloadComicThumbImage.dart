import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/service/pica.dart';

import 'Common.dart';

class DownloadComicThumbImage extends StatefulWidget {
  final double width;
  final double height;
  final String comicId;

  const DownloadComicThumbImage({
    Key? key,
    required this.width,
    required this.height,
    required this.comicId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadComicThumbImageState();
}

class _DownloadComicThumbImageState extends State<DownloadComicThumbImage> {
  late Future<RemoteImageData> _future;

  @override
  void initState() {
    _future = pica.downloadComicThumb(widget.comicId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return imageDataFutureBuilder(_future, widget.width, widget.height);
  }
}
