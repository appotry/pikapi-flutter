import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/basic/Pica.dart';
import '../basic/Entities.dart';
import 'SearchScreen.dart';
import 'components/ComicPager.dart';

// 分类详情 列表
class ComicsScreen extends StatefulWidget {
  final String? category;
  final String? tag;

  const ComicsScreen({
    Key? key,
    this.category,
    this.tag,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends State<ComicsScreen> {
  late SearchBar _categorySearchBar = SearchBar(
    hintText: '搜索分类 - ${categoryTitle(widget.category)}',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchScreen(keyword: value, category: widget.category),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: new Text(categoryTitle(widget.category)),
        actions: [_categorySearchBar.getSearchAction(context)],
      );
    },
  );

  late String _currentSort = SORT_DEFAULT;
  late int _currentPage = 1;
  late Future<ComicsPage> _future;

  void _load() {
    setState(() {
      _future = pica.comics(
        _currentSort,
        _currentPage,
        category: widget.category ?? "",
        tag: widget.tag ?? "",
      );
    });
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if (widget.category != null && widget.tag == null) {
      appBar = _categorySearchBar.build(context);
    } else if (widget.category == null && widget.tag != null) {
      appBar = AppBar(
        title: Text("标签 : ${widget.tag}"),
      );
    } else {
      appBar = AppBar(
        title: Text(
          "${widget.category ?? ""} ${widget.tag ?? ""}",
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: ComicPager(
        future: _future,
        onPageChange: (toPage) {
          _currentPage = toPage;
          _load();
        },
        onSortChange: (toSort) {
          if (toSort != null) {
            _currentSort = toSort;
            _load();
          }
        },
        onRefresh: () async {
          _load();
        },
        currentSort: _currentSort,
      ),
    );
  }
}
