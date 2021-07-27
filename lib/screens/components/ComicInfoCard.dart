import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';

import 'images/RemoteImage.dart';

class ComicInfoCard extends StatelessWidget {
  final ComicSimple info;

  const ComicInfoCard({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    var view = info is ComicInfo ? (info as ComicInfo).viewsCount : 0;
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildFinished(info.finished),
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
