import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapi/screens/SearchScreen.dart';
import 'package:pikapi/screens/components/ContentError.dart';
import 'package:pikapi/service/pica.dart';
import '../basic/Entities.dart' as models;
import 'CategoryPaperScreen.dart';
import 'components/ContentLoading.dart';
import 'components/images/Common.dart';
import 'components/images/RemoteImage.dart';

TextStyle noneLabelStyle = TextStyle(
  fontSize: 30,
);

class CategoriesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late SearchBar searchBar = SearchBar(
    hintText: '搜索',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(keyword: value),
          ),
        );
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: new Text('分类'),
        actions: [searchBar.getSearchAction(context)],
      );
    },
  );

  late Future<List<models.Category>> allFuture;

  @override
  void initState() {
    _setLoad();
    super.initState();
  }

  _setLoad() {
    setState(() {
      this.allFuture = _load();
    });
  }

  Future<List<models.Category>> _load() async {
    return pica.categories();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var background = theme.scaffoldBackgroundColor;
    var o = Color.fromARGB(
      0x11,
      255 - background.red,
      255 - background.green,
      255 - background.blue,
    );
    print(o.value);
    return Scaffold(
      appBar: searchBar.build(context),
      body: Container(
        color: o,
        child: FutureBuilder(
          future: allFuture,
          builder: ((BuildContext context,
              AsyncSnapshot<List<models.Category>> snapshot) {
            if (snapshot.hasError) {
              return ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  _setLoad();
                },
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return ContentLoading(label: '加载中');
            }
            return ListView(
              children: [
                Container(height: 20),
                Wrap(
                  children: _buildList(snapshot.data!),
                  runSpacing: 20,
                  alignment: WrapAlignment.spaceAround,
                ),
                Container(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  _buildList(List<models.Category> cList) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var blockSize = min / 3;
    var imageSize = blockSize - 15;
    var imageRs = imageSize / 10;

    List<Widget> list = [];

    list.add(
      GestureDetector(
        onTap: () {
          _navigateToCategory(null);
        },
        child: Container(
          width: blockSize,
          child: Column(
            children: [
              Card(
                elevation: .5,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(imageRs)),
                  child: buildMock(imageSize, imageSize),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(imageRs)),
                ),
              ),
              Container(height: 5),
              Center(
                child: Text('全分类'),
              ),
            ],
          ),
        ),
      ),
    );

    for (var i = 0; i < cList.length; i++) {
      var c = cList[i];
      if (c.isWeb) continue;
      list.add(
        GestureDetector(
          onTap: () {
            _navigateToCategory(c.title);
          },
          child: Container(
            width: blockSize,
            child: Column(
              children: [
                Card(
                  elevation: .5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(imageRs)),
                    child: RemoteImage(
                      fileServer: c.thumb.fileServer,
                      path: c.thumb.path,
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(imageRs)),
                  ),
                ),
                Container(height: 5),
                Center(
                  child: Text(
                    c.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }

  void _navigateToCategory(String? categoryTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPaperScreen(categoryTitle: categoryTitle),
      ),
    );
  }
}
