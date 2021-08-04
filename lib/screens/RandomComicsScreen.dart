import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/screens/components/ComicInfoCardLinked.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';

class RandomComicsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RandomComicsScreenState();
}

class _RandomComicsScreenState extends State<RandomComicsScreen> {
  Future<List<ComicSimple>> _future = pica.randomComics();

  Future<void> _reload() async {
    setState(() {
      _future = pica.randomComics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('随机本子'),
      ),
      body: ContentBuilder(
        future: _future,
        onRefresh: _reload,
        successBuilder:
            (BuildContext context, AsyncSnapshot<List<ComicSimple>> snapshot) {
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              children: [
                ...snapshot.data!.map((e) => LinkedComicInfoCard(e)),
                MaterialButton(
                  onPressed: _reload,
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: Text('刷新'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
