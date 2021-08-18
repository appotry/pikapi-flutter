import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';

class MyCommentsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyCommentsScreenState();
  }
}

class _MyCommentsScreenState extends State<MyCommentsScreen> {
  int _currentPage = 1;
  bool _loading = false;
  bool _over = false;
  late Future _future = _load();
  List<MyComment> _list = [];

  Future _load() async {
    try {
      _loading = false;
      var page = await pica.myComments(_currentPage);
      _over = page.page >= page.pages;
      _currentPage++;
      setState(() {
        _list.addAll(page.docs);
      });
    } finally {
      _loading = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我的评论')),
      body: ListView(
        padding: EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        children: [
          ..._buildList(),
          _buildLoading(),
        ],
      ),
    );
  }

  List<Widget> _buildList() {
    return _list.map((e) {
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              style: BorderStyle.solid,
              color: Colors.grey.shade500,
              width: 1,
            ),
            bottom: BorderSide(
              style: BorderStyle.solid,
              color: Colors.grey.shade500,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.comic.title,
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade500.withOpacity(.1),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: [Expanded(child: Text(e.content))],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildLoading() {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          print("${snapshot.error}\n${snapshot.stackTrace}");
          print(snapshot.data);
          return Container();
        }
        return Container();
      },
    );
  }
}
