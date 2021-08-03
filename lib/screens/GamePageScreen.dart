import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';

import 'GameInfoScreen.dart';
import 'components/Images.dart';

class GamesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  int _currentPage = 1;
  late Future<GamePage> _future = _loadPage();

  Future<GamePage> _loadPage() {
    return pica.games(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('游戏'),
      ),
      body: ContentBuilder(
        future: _future,
        onRefresh: _loadPage,
        successBuilder:
            (BuildContext context, AsyncSnapshot<GamePage> snapshot) {
          var page = snapshot.data!;

          List<Wrap> wraps = [];
          GameCard? gameCard;
          page.docs.forEach((element) {
            if (gameCard == null) {
              gameCard = GameCard(element);
            } else {
              wraps.add(Wrap(
                children: [GameCard(element), gameCard!],
                alignment: WrapAlignment.center,
              ));
              gameCard = null;
            }
          });
          if (gameCard != null) {
            wraps.add(Wrap(
              children: [gameCard!],
              alignment: WrapAlignment.center,
            ));
          }

          return ListView(
            children: [
              ...wraps,
            ],
          );
        },
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final GameSimple info;

  GameCard(this.info);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textColor = theme.textTheme.bodyText1!.color!;
    var textColorAlpha = textColor.withAlpha(0x33);
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // data.width/data.height = width/ ?
        //  data.width * ? = width * data.height
        // ? = width * data.height / data.width
        var size = MediaQuery.of(context).size;
        var min = size.width < size.height ? size.width : size.height;
        var imageWidth = (min - 45 - 40) / 2;
        var imageHeight = imageWidth * 280 / 500;
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GameInfoScreen(info.id)),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Container(
                width: imageWidth,
                child: Column(
                  children: [
                    RemoteImage(
                      width: imageWidth,
                      height: imageHeight,
                      fileServer: info.icon.fileServer,
                      path: info.icon.path,
                    ),
                    Text(
                      info.title + '\n',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(height: 1.4),
                      strutStyle: StrutStyle(height: 1.4),
                    ),
                    Text(
                      info.publisher,
                      style: categoriesStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
