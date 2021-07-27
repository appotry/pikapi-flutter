import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/service/pica.dart';

import 'Common.dart';

class RemoteImage extends StatefulWidget {
  final String fileServer;
  final String path;
  final double? width;
  final double? height;

  const RemoteImage({
    Key? key,
    required this.fileServer,
    required this.path,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<RemoteImage> {
  late bool _mock;
  late Future<RemoteImageData> _future;

  @override
  void initState() {
    _mock = widget.fileServer.contains("/wikawika.xyz/");
    if (!_mock) {
      _future = pica.remoteImageData(widget.fileServer, widget.path);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_mock) {
      return buildMock(widget.width, widget.height);
    }
    return imageDataFutureBuilder(_future, widget.width, widget.height);
  }
}
