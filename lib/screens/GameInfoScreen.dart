import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/screens/components/ContentError.dart';
import 'package:pikapi/screens/components/ContentLoading.dart';
import 'package:pikapi/screens/components/Images.dart';

class GameInfoScreen extends StatefulWidget {
  final String gameId;

  const GameInfoScreen(this.gameId);

  @override
  State<StatefulWidget> createState() => _GameInfoScreenState();
}

class _GameInfoScreenState extends State<GameInfoScreen> {
  late var _future = pica.game(widget.gameId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<GameInfo> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('加载出错'),
            ),
            body: ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = pica.game(widget.gameId);
                  });
                }),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('加载中'),
            ),
            body: ContentLoading(label: '加载中'),
          );
        }

        double iconMargin = 20;
        double iconSize = 60;
        BorderRadius iconRadius = BorderRadius.all(Radius.circular(6));
        TextStyle titleStyle =
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
        TextStyle publisherStyle = TextStyle(
          color: Theme.of(context).accentColor,
          fontSize: 12.5,
        );
        TextStyle versionStyle = TextStyle(
          fontSize: 12.5,
        );
        double screenShootMargin = 10;
        double screenShootHeight = 200;
        double platformMargin = 10;
        double platformSize = 25;
        TextStyle descriptionStyle = TextStyle();

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var min = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            var info = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text(info.title),
              ),
              body: ListView(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconMargin),
                        child: ClipRRect(
                          borderRadius: iconRadius,
                          child: RemoteImage(
                            width: iconSize,
                            height: iconSize,
                            fileServer: info.icon.fileServer,
                            path: info.icon.path,
                          ),
                        ),
                      ),
                      Container(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info.title, style: titleStyle),
                            Text(info.publisher, style: publisherStyle),
                            Text(info.version, style: versionStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: platformSize,
                    margin: EdgeInsets.only(bottom: platformMargin),
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: platformMargin,
                        right: platformMargin,
                      ),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          width: platformMargin,
                        ),
                        SvgPicture.asset(
                          'lib/assets/android.svg',
                          fit: BoxFit.contain,
                          width: platformSize,
                          height: platformSize ,
                          color: Colors.green.shade500,
                        ),
                        Container(
                          width: platformMargin,
                        ),
                        SvgPicture.asset(
                          'lib/assets/apple.svg',
                          fit: BoxFit.contain,
                          width: platformSize,
                          height: platformSize,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: screenShootMargin,
                      bottom: screenShootMargin,
                    ),
                    height: screenShootHeight,
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: screenShootMargin,
                        right: screenShootMargin,
                      ),
                      scrollDirection: Axis.horizontal,
                      children: info.screenshots
                          .map((e) => Container(
                                margin: EdgeInsets.only(
                                  left: screenShootMargin,
                                  right: screenShootMargin,
                                ),
                                child: ClipRRect(
                                  borderRadius: iconRadius,
                                  child: RemoteImage(
                                    height: screenShootHeight,
                                    fileServer: e.fileServer,
                                    path: e.path,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(iconMargin),
                    child: Text(info.description, style: descriptionStyle),
                  ),
                  Container(
                    color: Colors.grey.shade500.withOpacity(.1),
                    child: MaterialButton(
                      onPressed: () {
                        defaultToast(context, '通宵制作中');
                      },
                      child: Container(
                        padding: EdgeInsets.all(30),
                        child: Text('下载'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
