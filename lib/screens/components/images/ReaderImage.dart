import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/service/pica.dart';

import 'Common.dart';

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
