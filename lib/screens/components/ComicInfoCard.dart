import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/screens/SearchScreen.dart';
import 'package:pikapi/screens/common/Navigatior.dart';
import 'Images.dart';

// 漫画卡片
class ComicInfoCard extends StatefulWidget {
  final ComicSimple info;

  const ComicInfoCard({Key? key, required this.info}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoCard();
}

class _ComicInfoCard extends State<ComicInfoCard> {
  bool _favouriteLoading = false;

  @override
  Widget build(BuildContext context) {
    var info = widget.info;
    var theme = Theme.of(context);
    var categoriesStyle = makeCategoriesStyle(context);
    var view = info is ComicInfo ? info.viewsCount : 0;
    // bool? like = info is ComicInfo ? info.isLiked : null;
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
                      InkWell(
                        onTap: () {
                          navPushOrReplace(context,
                              (context) => SearchScreen(keyword: info.author));
                        },
                        child: Text(info.author, style: authorStyle),
                      ),
                      Container(height: 5),
                      Text("分类: " + info.categories.join(" "),
                          style: categoriesStyle),
                      Container(height: 5),
                      Row(
                        children: [
                          iconFavorite,
                          iconSpacing,
                          Text(
                            '${info.likesCount}',
                            style: iconLabelStyle,
                            strutStyle: iconLabelStrutStyle,
                          ),
                          iconMargin,
                          ...(view > 0
                              ? [
                                  iconVisibility,
                                  iconSpacing,
                                  Text(
                                    '$view',
                                    style: iconLabelStyle,
                                    strutStyle: iconLabelStrutStyle,
                                  )
                                ]
                              : []),
                          Container(width: 10),
                          iconMargin,
                          iconPage,
                          iconSpacing,
                          Text(
                            "${info.epsCount}E / ${info.pagesCount}P",
                            style: countLabelStyle,
                            strutStyle: iconLabelStrutStyle,
                          ),
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
                              _favouriteLoading
                                  ? IconButton(
                                      iconSize: 26,
                                      color: Colors.pink[400],
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.sync,
                                      ),
                                    )
                                  : IconButton(
                                      iconSize: 26,
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
      _favouriteLoading = true;
    });
    try {
      var rst = await pica.switchFavourite(widget.info.id);
      setState(() {
        (widget.info as ComicInfo).isFavourite = !rst.startsWith("un");
      });
    } finally {
      setState(() {
        _favouriteLoading = false;
      });
    }
  }
}

double imageWidth = 210 / 3.15;
double imageHeight = 315 / 3.15;

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

const double _iconSize = 15;

final iconFavorite =
    Icon(Icons.favorite, size: _iconSize, color: Colors.pink[400]);
final iconDownload =
    Icon(Icons.download_rounded, size: _iconSize, color: Colors.pink[400]);
final iconVisibility =
    Icon(Icons.visibility, size: _iconSize, color: Colors.pink[400]);

final iconLabelStyle = TextStyle(
  fontSize: 13,
  color: Colors.pink.shade400,
  height: 1.2,
);
final iconLabelStrutStyle = StrutStyle(
  height: 1.2,
);

final iconPage =
    Icon(Icons.ballot_outlined, size: _iconSize, color: Colors.grey);
final countLabelStyle = TextStyle(
  fontSize: 13,
  color: Colors.grey,
  height: 1.2,
);

final iconMargin = Container(width: 20);
final iconSpacing = Container(width: 5);

final titleStyle = TextStyle(fontWeight: FontWeight.bold);
final authorStyle = TextStyle(
  fontSize: 13,
  color: Colors.pink.shade300,
);

TextStyle makeCategoriesStyle(BuildContext context) => TextStyle(
      fontSize: 13,
      color: Theme.of(context).textTheme.bodyText1!.color!.withAlpha(0xCC),
    );
