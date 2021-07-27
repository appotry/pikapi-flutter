import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pikapi/service/pica.dart';

import 'Common.dart';

abstract class FutureImageA extends StatefulWidget {
  Future<Uint8List> _makeFuture();

  FutureImageA({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FutureImageAState();
}

class _FutureImageAState extends State<FutureImageA>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<Uint8List> _future = widget._makeFuture();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        return FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
            if (snapshot.hasError) {
              return buildError(width, width / 2);
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading(width, width / 2);
            }
            return Image.memory(
              snapshot.data!,
              width: width,
              errorBuilder: (a, b, c) => Container(
                width: width,
                height: width / 2,
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

class ComicReaderImage extends FutureImageA {
  final String fileServer;
  final String path;

  ComicReaderImage({
    Key? key,
    required this.fileServer,
    required this.path,
  }) : super(key: key);

  @override
  Future<Uint8List> _makeFuture() async {
    return (await pica.remoteImageData(fileServer, path)).buff;
  }
}

class ComicReaderImageFile extends FutureImageA {
  final String filePath;

  ComicReaderImageFile({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  Future<Uint8List> _makeFuture() async {
    return await (File(filePath).readAsBytes());
  }
}
