import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';

// 来自下载
class DownloadReaderImage extends ReaderImage {
  final DownloadPicture downloadPicture;

  DownloadReaderImage(this.downloadPicture);

  @override
  Future<RemoteImageData> imageData() async {
    if (downloadPicture.localPath == "") {
      return pica.remoteImageData(
        downloadPicture.fileServer,
        downloadPicture.path,
      );
    }
    var finalPath = await pica.downloadImagePath(downloadPicture.localPath);
    return RemoteImageData.forData(
      downloadPicture.fileSize,
      downloadPicture.format,
      downloadPicture.width,
      downloadPicture.height,
      finalPath,
    );
  }
}

// 来自远端
class RemoteReaderImage extends ReaderImage {
  final String fileServer;
  final String path;

  RemoteReaderImage({
    Key? key,
    required this.fileServer,
    required this.path,
  }) : super(key: key);

  @override
  Future<RemoteImageData> imageData() async {
    return pica.remoteImageData(fileServer, path);
  }
}

// 平铺到整个页面的图片
abstract class ReaderImage extends StatefulWidget {
  ReaderImage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReaderImageState();

  Future<RemoteImageData> imageData();
}

class _ReaderImageState extends State<ReaderImage> {
  late Future<RemoteImageData> _future = widget.imageData();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        return FutureBuilder(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot<RemoteImageData> snapshot,
          ) {
            if (snapshot.hasError) {
              return buildError(width, width / 2);
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading(width, width / 2);
            }
            var data = snapshot.data!;
            var height = width * data.height / data.width;
            // data.width/data.height = width/ ?
            //  data.width * ? = width * data.height
            // ? = width * data.height / data.width
            return Image.file(
              File(data.finalPath),
              width: width,
              height: height,
              errorBuilder: (a, b, c) => Container(
                width: width,
                height: height,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: width / 2.5,
                  ),
                ),
              ),
              fit: BoxFit.cover,
            );
          },
        );
      },
    );
  }
}

// 下载的图片
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

// 远端图片
class RemoteImage extends StatefulWidget {
  final String fileServer;
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RemoteImage({
    Key? key,
    required this.fileServer,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<RemoteImage> {
  late bool _mock;
  late Future<String> _future;

  @override
  void initState() {
    _mock =
        widget.fileServer == "" || widget.fileServer.contains("/wikawika.xyz/");
    if (!_mock) {
      _future = pica
          .remoteImageData(widget.fileServer, widget.path)
          .then((value) => value.finalPath);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_mock) {
      return buildMock(widget.width, widget.height);
    }
    return pathFutureImage(_future, widget.width, widget.height,
        fit: widget.fit);
  }
}

// 通用方法

final defaultSvgColor = Colors.grey.shade600;

Widget buildSvg(String source, double? width, double? height, {Color? color}) {
  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(10),
    child: Center(
      child: SvgPicture.asset(
        source,
        width: width,
        height: height,
        color: color ?? defaultSvgColor,
      ),
    ),
  );
}

Widget buildMock(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(10),
    child: Center(
      child: SvgPicture.asset(
        'lib/assets/unknown.svg',
        width: width,
        height: height,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

Widget buildError(double? width, double? height) {
  return Image(
    image: AssetImage('lib/assets/error.png'),
    width: width,
    height: height,
  );
}

Widget buildLoading(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    child: Center(
      child: Icon(
        Icons.downloading,
        size: width,
        color: Colors.black12,
      ),
    ),
  );
}

Widget buildFile(String file, double? width, double? height,
    {BoxFit fit = BoxFit.cover}) {
  return Image.file(
    File(file),
    width: width,
    height: height,
    errorBuilder: (a, b, c) {
      print("$b");
      print("$c");
      return buildError(width, height);
    },
    fit: fit,
  );
}

Widget pathFutureImage(Future<String> future, double? width, double? height,
    {BoxFit fit = BoxFit.cover}) {
  return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}");
          print("${snapshot.stackTrace}");
          return buildError(width, height);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoading(width, height);
        }
        return buildFile(snapshot.data!, width, height, fit: fit);
      });
}
