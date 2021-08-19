import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/enum/ListLayout.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/screens/components/ComicList.dart';
import 'package:pikapi/screens/components/ContentError.dart';
import 'package:pikapi/screens/components/FitButton.dart';
import 'package:pikapi/screens/components/Images.dart';
import 'ComicInfoCard.dart';
import 'LinkToComicInfo.dart';
import 'ContentLoading.dart';

// 漫画列页
class ComicPager extends StatefulWidget {
  final Future<ComicsPage> future;
  final String currentSort;
  final void Function(String?) onSortChange;
  final void Function(int) onPageChange;
  final Future<void> Function() onRefresh;

  const ComicPager({
    Key? key,
    required this.future,
    required this.currentSort,
    required this.onSortChange,
    required this.onPageChange,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicPagerState();
}

class _ComicPagerState extends State<ComicPager> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (BuildContext context, AsyncSnapshot<ComicsPage> snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return Text('初始化');
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return ContentLoading(label: '加载中');
        }
        if (snapshot.hasError) {
          return ContentError(
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
              onRefresh: widget.onRefresh);
        }
        var comicsPage = snapshot.data!;
        return Scaffold(
          appBar: _buildAppBar(comicsPage, context),
          body: ComicList(
            comicsPage.docs,
            appendWidget: _buildNextButton(comicsPage),
          ),
        );
      },
    );
  }

  PreferredSize _buildAppBar(ComicsPage comicsPage, BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(40),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: .5,
              style: BorderStyle.solid,
              color: Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 10),
                DropdownButton(
                  items: items,
                  value: widget.currentSort,
                  onChanged: widget.onSortChange,
                ),
              ],
            ),
            InkWell(
              onTap: () {
                _textEditController.clear();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Card(
                        child: Container(
                          child: TextField(
                            controller: _textEditController,
                            decoration: new InputDecoration(
                              labelText: "请输入页数：",
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'\d+')),
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('取消'),
                        ),
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            var text = _textEditController.text;
                            if (text.length == 0 || text.length > 5) {
                              return;
                            }
                            var num = int.parse(text);
                            if (num == 0 || num > comicsPage.pages) {
                              return;
                            }
                            widget.onPageChange(num);
                          },
                          child: Text('确定'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Text("第 ${comicsPage.page} / ${comicsPage.pages} 页"),
                ],
              ),
            ),
            Row(
              children: [
                MaterialButton(
                  minWidth: 0,
                  onPressed: () {
                    if (comicsPage.page > 1) {
                      widget.onPageChange(comicsPage.page - 1);
                    }
                  },
                  child: Text('上一页'),
                ),
                MaterialButton(
                  minWidth: 0,
                  onPressed: () {
                    if (comicsPage.page < comicsPage.pages) {
                      widget.onPageChange(comicsPage.page + 1);
                    }
                  },
                  child: Text('下一页'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildNextButton(ComicsPage comicsPage) {
    if (comicsPage.page < comicsPage.pages) {
      return FitButton(
        onPressed: () => widget.onPageChange(comicsPage.page + 1),
        text: '下一页',
      );
    }
  }
}

final TextEditingController _textEditController =
    TextEditingController(text: '');
