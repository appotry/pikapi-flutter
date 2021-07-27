import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/service/pica.dart';

import 'images/RemoteImage.dart';

class ComicInfoCard extends StatefulWidget {
  final ComicSimple info;

  const ComicInfoCard({Key? key, required this.info}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoCard();
}

class _ComicInfoCard extends State<ComicInfoCard> {
  bool favouriteLoading = false;

  @override
  Widget build(BuildContext context) {
    var info = widget.info;
    var theme = Theme.of(context);
    var textColor = theme.textTheme.bodyText1!.color!;
    var textColorSummary = textColor.withAlpha(0xCC);
    var titleStyle = TextStyle(
      color: textColor,
      fontWeight: FontWeight.bold,
    );
    var categoriesStyle = TextStyle(
      fontSize: 13,
      color: textColorSummary,
    );
    var authorStyle = TextStyle(
      fontSize: 13,
      color: Colors.pink.shade300,
    );
    var iconColor = Colors.pink.shade400;
    var iconLabelStyle = TextStyle(
      fontSize: 13,
      color: iconColor,
    );
    var view = info is ComicInfo ? info.viewsCount : 0;
    bool? like = info is ComicInfo ? info.isLiked : null;
    bool? favourite = info is ComicInfo ? (info).isFavourite : null;
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(right: 10),
            child: RemoteImage(
              fileServer: info.thumb.fileServer,
              path: info.thumb.path,
              width: imageWidth,
              height: imageHeight,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.title, style: titleStyle),
                      Container(height: 5),
                      Text(info.author, style: authorStyle),
                      Container(height: 5),
                      Text("分类: " + info.categories.join(" "),
                          style: categoriesStyle),
                      Container(height: 5),
                      Row(
                        children: [
                          Icon(Icons.favorite,
                              size: iconSize, color: Colors.pink[400]),
                          Container(width: 5),
                          Text(
                            '${info.likesCount}',
                            style: iconLabelStyle,
                          ),
                          Container(width: 20),
                          ...(view > 0
                              ? [
                                  Icon(Icons.visibility,
                                      size: iconSize, color: Colors.pink[400]),
                                  Container(width: 5),
                                  Text(
                                    '$view',
                                    style: iconLabelStyle,
                                  )
                                ]
                              : []),
                          Expanded(child: Container()),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 8),
                  height: imageHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildFinished(info.finished),
                      Expanded(child: Container()),
                      ...(favourite == null
                          ? []
                          : [
                              favouriteLoading
                                  ? IconButton(
                                      iconSize: iconSize * 2,
                                      color: Colors.pink[400],
                                      onPressed: (){},
                                      icon: Icon(
                                        Icons.sync,
                                      ),
                                    )
                                  : IconButton(
                                      iconSize: iconSize * 2,
                                      color: Colors.pink[400],
                                      onPressed: _changeFavourite,
                                      icon: Icon(
                                        favourite
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                      ),
                                    ),
                            ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _changeFavourite() async {
    setState(() {
      favouriteLoading = true;
    });
    try {
      var rst = await pica.switchFavourite(widget.info.id);
      setState(() {
        (widget.info as ComicInfo).isFavourite = !rst.startsWith("un");
      });
    } finally {
      setState(() {
        favouriteLoading = false;
      });
    }
  }
}

double imageWidth = 210 / 3.15;
double imageHeight = 315 / 3.15;
double iconSize = 15;

Widget buildFinished(bool comicFinished) {
  if (comicFinished) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        "完结",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
        strutStyle: StrutStyle(
          height: 1.2,
        ),
      ),
    );
  }
  return Container();
}
