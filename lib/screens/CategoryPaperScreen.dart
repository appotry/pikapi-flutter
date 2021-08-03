import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/basic/Pica.dart';
import '../basic/Entities.dart';
import 'SearchScreen.dart';
import 'components/ComicPager.dart';

// 分类详情 列表
class CategoryPaperScreen extends StatefulWidget {
  final String? categoryTitle;

  const CategoryPaperScreen({Key? key, required this.categoryTitle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoryPaperScreenState();
}

class _CategoryPaperScreenState extends State<CategoryPaperScreen> {

  late SearchBar searchBar = SearchBar(
    hintText: '搜索 - ${categoryTitle(widget.categoryTitle)}',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchScreen(keyword: value, category: widget.categoryTitle),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: new Text(categoryTitle(widget.categoryTitle)),
        actions: [searchBar.getSearchAction(context)],
      );
    },
  );

  late String _currentSort = SORT_DEFAULT;
  late int _currentPage = 1;
  late Future<ComicsPage> _future;

  void _load() {
    setState(() {
      _future =
          pica.comics(widget.categoryTitle ?? "", _currentSort, _currentPage);
    });
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
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
