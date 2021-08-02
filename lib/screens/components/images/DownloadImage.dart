import 'package:flutter/cupertino.dart';
import 'package:pikapi/service/pica.dart';

import 'Common.dart';

class DownloadImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;

  const DownloadImage({
    Key? key,
    required this.path,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadImageState();
}

class _DownloadImageState extends State<DownloadImage> {
  late Future<String> _future = pica.downloadImagePath(widget.path);

  @override
  Widget build(BuildContext context) {
    return pathFutureImage(_future, widget.width, widget.height);
  }
}
