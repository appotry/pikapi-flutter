import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/screens/components/ItemBuilder.dart';
import 'package:pikapi/basic/Pica.dart';
import 'PicaAvatar.dart';

// 漫画的评论列表
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
            _buildPrePage(page),
            ...page.docs.map((e) => _buildComment(e)),
            _buildPostComment(),
            _buildNextPage(page),
          ],
        );
      },
      onRefresh: () async => {
        setState(() {
          _future = _loadPage();
        })
      },
    );
  }

  Widget _buildComment(Comment e) {
    var theme = Theme.of(context);
    var nameStyle = TextStyle(fontWeight: FontWeight.bold);
    var levelStyle = TextStyle(
        fontSize: 12, color: theme.colorScheme.secondary.withOpacity(.8));
    var connectStyle =
        TextStyle(color: theme.textTheme.bodyText1?.color?.withOpacity(.8));
    var datetimeStyle = TextStyle(
        color: theme.textTheme.bodyText1?.color?.withOpacity(.6), fontSize: 12);
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
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(e.user.name, style: nameStyle),
                          Text(formatTimeToDateTime(e.createdAt),
                              style: datetimeStyle),
                        ],
                      ),
                    );
                  },
                ),
                Container(height: 3),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text("Lv. ${e.user.level} (${e.user.title})",
                              style: levelStyle),
                          e.commentsCount > 0
                              ? Text.rich(TextSpan(children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(Icons.message,
                                        size: 13,
                                        color: theme.colorScheme.secondary
                                            .withOpacity(.7)),
                                  ),
                                  WidgetSpan(child: Container(width: 5)),
                                  TextSpan(
                                      text: '${e.commentsCount}',
                                      style: levelStyle),
                                ]))
                              : Container(),
                        ],
                      ),
                    );
                  },
                ),
                Container(height: 5),
                Text(e.content, style: connectStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostComment() {
    return InkWell(
      onTap: () async {
        String? text = await inputString(context, '请输入评论内容');
        if (text != null && text.isNotEmpty) {
          try {
            await pica.postComment(widget.comicId, text);
            setState(() {
              _future = _loadPage();
            });
          } catch (e) {
            defaultToast(context, "评论失败");
          }
        }
      },
      child: Container(
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
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text('我有话要讲'),
        ),
      ),
    );
  }

  Widget _buildPrePage(CommentPage page) {
    if (page.page > 1) {
      return InkWell(
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
      );
    }
    return Container();
  }

  Widget _buildNextPage(CommentPage page) {
    if (page.page < page.pages) {
      return InkWell(
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
      );
    }
    return Container();
  }
}
