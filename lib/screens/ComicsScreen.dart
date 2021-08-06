import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/enum/Sort.dart';
import 'package:pikapi/basic/Pica.dart';
import '../basic/Entities.dart';
import 'SearchScreen.dart';
import 'components/ComicPager.dart';

// 漫画列表
class ComicsScreen extends StatefulWidget {
  final String? category; // 指定分类
  final String? tag; // 指定标签
  final String? creatorId; // 指定上传者
  final String? creatorName; // 上传者名称 (仅显示)
  final String? chineseTeam;

  const ComicsScreen({
    Key? key,
    this.category,
    this.tag,
    this.creatorId,
    this.creatorName,
    this.chineseTeam,
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
        creatorId: widget.creatorId ?? "",
        chineseTeam: widget.chineseTeam ?? "",
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
    if (widget.tag == null &&
        widget.creatorId == null &&
        widget.chineseTeam == null) {
      // 只有只传分类或不传参数时时才开放搜索
      appBar = _categorySearchBar.build(context);
    } else {
      var title = "";
      if (widget.category != null) {
        title += "${widget.category} ";
      }
      if (widget.tag != null) {
        title += "${widget.tag} ";
      }
      if (widget.creatorName != null) {
        title += "${widget.creatorName} ";
      }
      if (widget.chineseTeam != null) {
        title += "${widget.chineseTeam} ";
      }
      appBar = AppBar(
        title: Text(title),
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
