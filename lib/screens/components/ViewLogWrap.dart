import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Images.dart';

class ViewLogWrapEntity {
  final String id;
  final String title;
  final String fileServer;
  final String path;
  final bool deleted;

  ViewLogWrapEntity(this.id, this.title, this.fileServer, this.path,
      {this.deleted = false});
}

class ViewLogWrap extends StatelessWidget {
  final Function(String) onTapComic;
  final List<ViewLogWrapEntity> comics;
  final Function(String id) onDelete;

  const ViewLogWrap({
    Key? key,
    required this.onTapComic,
    required this.comics,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var width = (min - 45) / 4;
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: comics.map((e) {
        if (e.deleted) {
          return Card(
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
                    '已删除\n',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(height: 1.4),
                    strutStyle: StrutStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () {
              onTapComic(e.id);
            },
            onLongPress: () {
              onDelete(e.id);
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
          );
        }
      }).toList(),
    );
  }
}
