import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/screens/components/ComicInfoCardLinked.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';

import 'components/ComicsListBuilder.dart';

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
      body: ComicListBuilder(_future, _reload),
    );
  }
}
