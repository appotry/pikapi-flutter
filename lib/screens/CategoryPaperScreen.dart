import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/service/pica.dart';
import '../basic/Entities.dart';
import 'SearchScreen.dart';
import 'components/ComicPager.dart';

class CategoryPaperScreen extends StatefulWidget {
  final String? categoryTitle;

  const CategoryPaperScreen({Key? key, required this.categoryTitle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CategoryPaperScreenState();
}

class _CategoryPaperScreenState extends State<CategoryPaperScreen> {
  late SearchBar searchBar = SearchBar(
    hintText: '搜索 - ${widget.categoryTitle ?? "全分类"}',
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
        title: new Text(widget.categoryTitle??"全分类"),
        actions: [searchBar.getSearchAction(context)],
      );
    },
  );

  late Future<ComicsPage> _future;
  late String _currentSort = SORT_DEFAULT;
  late int _currentPage = 1;

  @override
  void initState() {
    _load();
    super.initState();
  }

  void _load() {
    setState(() {
      _future = pica.comics(widget.categoryTitle??"", _currentSort, _currentPage);
    });
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
