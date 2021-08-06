import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';

import 'components/ComicsListBuilder.dart';

class RankingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('排行榜'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              height: 40,
              color: theme.colorScheme.secondary.withOpacity(.025),
              child: TabBar(
                indicatorColor: theme.colorScheme.secondary,
                labelColor: theme.colorScheme.secondary,
                tabs: [
                  Tab(text: '天'),
                  Tab(text: '周'),
                  Tab(text: '月'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _Leaderboard("H24"),
                  _Leaderboard("D7"),
                  _Leaderboard("D30"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Leaderboard extends StatefulWidget {
  final String type;

  _Leaderboard(this.type);

  @override
  State<StatefulWidget> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<_Leaderboard> {
  late Future<List<ComicSimple>> _future = pica.leaderboard(widget.type);

  Future<void> _reload() async {
    setState(() {
      _future = pica.leaderboard(widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComicListBuilder(_future, _reload);
  }
}
