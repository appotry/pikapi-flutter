import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Images.dart';

class ComicWrapEntity {
  final String id;
  final String title;
  final String fileServer;
  final String path;

  ComicWrapEntity(this.id, this.title, this.fileServer, this.path);
}

class ComicWrap extends StatelessWidget {
  final Function(String) onTapComic;
  final List<ComicWrapEntity> comics;

  const ComicWrap({
    Key? key,
    required this.onTapComic,
    required this.comics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var width = (min - 45) / 4;
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: comics
          .map((e) => InkWell(
                onTap: () {
                  onTapComic(e.id);
                },
                child: Card(
                  child: Container(
                    width: width,
                    child: Column(
                      children: [
                        LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return RemoteImage(
                              width: constraints.maxWidth,
                              fileServer: e.fileServer,
                              path: e.path);
                        }),
                        Text(
                          e.title + '\n',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(height: 1.4),
                          strutStyle: StrutStyle(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
