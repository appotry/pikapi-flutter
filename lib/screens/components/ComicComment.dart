import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/ItemBuilder.dart';
import 'package:pikapi/screens/components/images/RemoteImage.dart';
import 'package:pikapi/service/pica.dart';

import 'PicaAvatar.dart';

class ComicComment extends StatefulWidget {
  final String comicId;

  ComicComment(this.comicId);

  @override
  State<StatefulWidget> createState() => _ComicCommentState();
}

class _ComicCommentState extends State<ComicComment> {
  late int _currentPage = 1;
  late Future<CommentPage> _future = _loadPage();

  Future<CommentPage> _loadPage() {
    return pica.comments(widget.comicId, _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return ItemBuilder(
      future: _future,
      successBuilder:
          (BuildContext context, AsyncSnapshot<CommentPage> snapshot) {
        var page = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            page.page > 1
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _currentPage = page.page - 1;
                        _future = _loadPage();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text('上一页'),
                      ),
                    ),
                  )
                : Container(),
            ...page.docs.map((e) => _buildComment(e)),
            page.page < page.pages
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _currentPage = page.page + 1;
                        _future = _loadPage();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text('下一页'),
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      },
      onRefresh: () async => setState(() => _future = _loadPage()),
    );
  }

  Widget _buildComment(Comment e) {
    var theme = Theme.of(context);
    var nameStyle = TextStyle(fontWeight: FontWeight.bold);
    var levelStyle =
        TextStyle(fontSize: 12, color: theme.accentColor.withOpacity(.8));
    var connectStyle =
        TextStyle(color: theme.textTheme.bodyText1?.color?.withOpacity(.8));
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: .25,
            style: BorderStyle.solid,
            color: Colors.grey.shade500.withOpacity(.5),
          ),
          bottom: BorderSide(
            width: .25,
            style: BorderStyle.solid,
            color: Colors.grey.shade500.withOpacity(.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PicaAvatar(e.user.avatar),
          Container(width: 5),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.user.name, style: nameStyle),
              Text("Lv. ${e.user.level} (${e.user.title})", style: levelStyle),
              Container(height: 3),
              Text(e.content, style: connectStyle),
            ],
          )),
        ],
      ),
    );
  }
}
