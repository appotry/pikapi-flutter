import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/basic/Pica.dart';
import '../basic/Entities.dart';
import 'components/ComicPager.dart';

class SearchScreen extends StatefulWidget {
  final String keyword;
  final String? category;

  const SearchScreen({
    Key? key,
    required this.keyword,
    this.category,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _textEditController =
      TextEditingController(text: widget.keyword);
  late SearchBar _searchBar = SearchBar(
    hintText: '搜索 ${categoryTitle(widget.category)}',
    controller: _textEditController,
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(
              keyword: value,
              category: widget.category,
            ),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: Text("${categoryTitle(widget.category)} ${widget.keyword}"),
        actions: [_searchBar.getSearchAction(context)],
      );
    },
  );
  late Future<ComicsPage> _future;
  String _currentSort = SORT_DEFAULT;
  int _currentPage = 1;

  void _load() {
    setState(() {
      if (widget.category == null) {
        _future = pica.searchComics(widget.keyword, _currentSort, _currentPage);
      } else {
        _future = pica.searchComicsInCategories(
          widget.keyword,
          _currentSort,
          _currentPage,
          [widget.category!],
        );
      }
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
      appBar: _searchBar.build(context),
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
