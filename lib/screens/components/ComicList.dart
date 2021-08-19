import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/enum/ListLayout.dart';

import 'ComicInfoCard.dart';
import 'Images.dart';
import 'LinkToComicInfo.dart';

class ComicList extends StatefulWidget {
  final Widget? appendWidget;
  final List<ComicSimple> comicList;

  const ComicList(this.comicList, {this.appendWidget});

  @override
  State<StatefulWidget> createState() => _ComicListState();
}

class _ComicListState extends State<ComicList> {
  @override
  void initState() {
    listLayoutEvent.subscribe(_onLayoutChange);
    super.initState();
  }

  @override
  void dispose() {
    listLayoutEvent.unsubscribe(_onLayoutChange);
    super.dispose();
  }

  void _onLayoutChange(ListLayoutArgs? args) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (currentLayout) {
      case ListLayout.INFO_CARD:
        return _buildInfoCardList();
      case ListLayout.ONLY_IMAGE:
        return _buildGridImageWarp();
      default:
        return Container();
    }
  }

  Widget _buildGridImageWarp() {
    var gap = 3.0;
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var widthAndGap = min / 4;
    int rowCap = size.width ~/ widthAndGap;
    var width = widthAndGap - gap * 2;
    var height = width * coverHeight / coverWidth;
    List<Widget> wraps = [];
    List<Widget> tmp = [];
    widget.comicList.forEach((e) {
      tmp.add(LinkToComicInfo(
        comicId: e.id,
        child: Container(
          padding: EdgeInsets.all(gap),
          child: RemoteImage(
            fileServer: e.thumb.fileServer,
            path: e.thumb.path,
            width: width,
            height: height,
          ),
        ),
      ));
      if (tmp.length == rowCap) {
        wraps.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tmp,
        ));
        tmp = [];
      }
    });
    // 追加特殊按钮
    if (widget.appendWidget != null) {
      tmp.add(Container(
        color: (Theme.of(context).textTheme.bodyText1?.color ?? Color(0))
            .withOpacity(.1),
        margin: EdgeInsets.only(
          left: (rowCap - tmp.length) * gap,
          right: (rowCap - tmp.length) * gap,
          top: gap,
          bottom: gap,
        ),
        width: (rowCap - tmp.length) * width,
        height: height,
        child: widget.appendWidget,
      ));
    }
    // 最后一页没有下一页所有有可能为空
    if (tmp.length > 0) {
      wraps.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tmp,
      ));
      tmp = [];
    }
    // 返回
    return ListView(
      padding: EdgeInsets.only(top: gap, bottom: gap),
      children: wraps,
    );
  }

  Widget _buildInfoCardList() {
    return ListView(
      children: [
        ...widget.comicList
            .map((e) => LinkToComicInfo(
                  comicId: e.id,
                  child: ComicInfoCard(e),
                ))
            .toList(),
        ...widget.appendWidget != null
            ? [
                Container(
                  height: 80,
                  child: widget.appendWidget,
                ),
              ]
            : [],
      ],
    );
  }
}
