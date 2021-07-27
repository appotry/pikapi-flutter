import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/service/pica.dart';
import '../basic/Entities.dart';
import 'SearchScreen.dart';
import 'components/ComicPager.dart';

class FavouritePaperScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FavouritePaperScreen();
}

class _FavouritePaperScreen extends State<FavouritePaperScreen> {
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
      _future = pica.favouriteComics(_currentSort, _currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('收藏'),
      ),
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
