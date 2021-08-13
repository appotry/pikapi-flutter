import 'dart:async';
import 'dart:io';

import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/enum/PagerType.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../FilePhotoViewScreen.dart';
import 'gesture_zoom_box.dart';

import 'Images.dart';

class ReaderImageInfo {
  final String fileServer;
  final String path;
  final String? localPath;
  final int? width;
  final int? height;
  final String? format;
  final int? fileSize;

  ReaderImageInfo(this.fileServer, this.path, this.localPath, this.width,
      this.height, this.format, this.fileSize);
}

class ImageReaderStruct {
  final List<ReaderImageInfo> images;
  final bool fullScreen;
  final FutureOr<dynamic> Function(bool fullScreen) onFullScreenChange;
  final FutureOr<dynamic> Function() onNextEp;
  final FutureOr<dynamic> Function(int) onPositionChange;
  final int? initPosition;

  const ImageReaderStruct({
    required this.images,
    required this.fullScreen,
    required this.onFullScreenChange,
    required this.onNextEp,
    required this.onPositionChange,
    this.initPosition,
  });
}

class ImageReader extends StatefulWidget {
  final ImageReaderStruct struct;

  const ImageReader(this.struct);

  @override
  State<StatefulWidget> createState() => _ImageReaderState();
}

class _ImageReaderState extends State<ImageReader> {
  Future<PagerType> _future = pica.loadPagerType();

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(
      future: _future,
      onRefresh: () async {
        setState(() {
          _future = pica.loadPagerType();
        });
      },
      successBuilder:
          (BuildContext context, AsyncSnapshot<PagerType> snapshot) {
        switch (snapshot.data!) {
          case PagerType.WEB_TOON:
            return _WebToonReader(widget.struct);
          case PagerType.WEB_TOON_ZOOM:
            return _WebToonZoomReader(widget.struct);
          case PagerType.WEB_TOON_PAGE:
            return _WebToonPageReader(widget.struct);
          default:
            return Container();
        }
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonReader extends StatefulWidget {
  final ImageReaderStruct struct;

  const _WebToonReader(this.struct);

  @override
  State<StatefulWidget> createState() => _WebToonReaderState();
}

class _WebToonReaderState extends State<_WebToonReader> {
  late final List<_WebToonImageProportionSize> _sizes = [];
  late final List<Widget> _images = [];
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;
  late final int _initialPosition;

  var _current = 1;
  var _slider = 1;

  void _onCurrentChange() {
    var to = _itemPositionsListener.itemPositions.value.first.index + 1;
    if (_current != to) {
      setState(() {
        _current = to;
        _slider = to;
        if (to - 1 < widget.struct.images.length) {
          widget.struct.onPositionChange(to - 1);
        }
      });
    }
  }

  @override
  void initState() {
    var index = 0;
    widget.struct.images.forEach((e) {
      if (e.localPath != null) {
        _sizes.add(_WebToonImageProportionSize(e.width!, e.height!));
        _images.add(_WebToonDownloadImage(
          fileServer: e.fileServer,
          path: e.path,
          localPath: e.localPath!,
          fileSize: e.fileSize!,
          width: e.width!,
          height: e.height!,
          format: e.format!,
          sizeList: _sizes,
          indexOfSizeList: index++,
        ));
      } else {
        _sizes.add(_WebToonImageProportionSize(2, 1));
        _images.add(_WebToonRemoteImage(e.fileServer, e.path, _sizes, index++));
      }
    });
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onCurrentChange);
    if (widget.struct.initPosition != null &&
        widget.struct.images.length > widget.struct.initPosition!) {
      _initialPosition = widget.struct.initPosition!;
    } else {
      _initialPosition = 0;
    }
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onCurrentChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          _buildList(),
          ..._buildControllers(),
        ],
      ),
    );
  }

  Widget _buildList() {
    var scaffold = Scaffold.of(context);
    return ScrollablePositionedList.builder(
      initialScrollIndex: _initialPosition,
      padding: widget.struct.fullScreen
          ? EdgeInsets.only(
              top: scaffold.appBarMaxHeight ?? 0,
              bottom: scaffold.appBarMaxHeight ?? 0,
            )
          : null,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      itemCount: widget.struct.images.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (widget.struct.images.length == index) {
          return _buildNextEp();
        }
        return _images[index];
      },
    );
  }

  List<Widget> _buildControllers() {
    if (widget.struct.fullScreen) {
      return [
        _buildFullScreenController(),
      ];
    }
    return [
      _buildFullScreenController(),
      _buildScrollController(),
    ];
  }

  Widget _buildFullScreenController() {
    return Container(
      child: Column(
        children: [
          Expanded(child: Container()),
          Row(
            children: [
              Material(
                color: Color(0x0),
                child: Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Color(0x88000000),
                  ),
                  margin: EdgeInsets.only(bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      widget.struct
                          .onFullScreenChange(!widget.struct.fullScreen);
                    },
                    child: Icon(
                      widget.struct.fullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollController() {
    if (widget.struct.images.length == 0) {
      return Container();
    }
    var theme = Theme.of(context);
    return Container(
      child: Row(
        children: [
          Expanded(child: Container()),
          Material(
            color: Color(0x0),
            child: Container(
              width: 40,
              height: 300,
              decoration: BoxDecoration(
                color: Color(0x66000000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 8),
              child: Center(
                child: FlutterSlider(
                  axis: Axis.vertical,
                  values: [
                    (_slider > widget.struct.images.length
                            ? widget.struct.images.length
                            : _slider)
                        .toDouble()
                  ],
                  max: widget.struct.images.length.toDouble(),
                  min: 1,
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    double a = lowerValue;
                    _slider = a.toInt();
                  },
                  onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                    if (_slider != _current && _slider > 0) {
                      _itemScrollController.jumpTo(index: _slider - 1);
                    }
                  },
                  trackBar: FlutterSliderTrackBar(
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade300,
                    ),
                    activeTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  step: FlutterSliderStep(
                    step: 1,
                    isPercentRange: false,
                  ),
                  tooltip: FlutterSliderTooltip(custom: (value) {
                    double a = value;
                    return Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.white,
                      child: Text('${a.toInt()}',
                          style: TextStyle(color: Colors.black)),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextEp() {
    return Container(
      padding: EdgeInsets.all(20),
      child: MaterialButton(
        onPressed: widget.struct.onNextEp,
        textColor: Colors.white,
        child: Container(
          padding: EdgeInsets.only(top: 40, bottom: 40),
          child: Text("下一章"),
        ),
      ),
    );
  }
}

// 来自下载
class _WebToonDownloadImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;
  final String localPath;
  final int fileSize;
  final int width;
  final int height;
  final String format;

  _WebToonDownloadImage({
    required this.fileServer,
    required this.path,
    required this.localPath,
    required this.fileSize,
    required this.width,
    required this.height,
    required this.format,
    required List<_WebToonImageProportionSize> sizeList,
    required int indexOfSizeList,
  }) : super(sizeList, indexOfSizeList);

  @override
  Future<RemoteImageData> imageData() async {
    if (localPath == "") {
      return pica.remoteImageData(fileServer, path);
    }
    var finalPath = await pica.downloadImagePath(localPath);
    return RemoteImageData.forData(
      fileSize,
      format,
      width,
      height,
      finalPath,
    );
  }
}

class _WebToonImageProportionSize {
  final int width;
  final int height;

  _WebToonImageProportionSize(this.width, this.height);

  @override
  String toString() {
    return " { $width , $height } ";
  }
}

// 来自远端
class _WebToonRemoteImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;

  _WebToonRemoteImage(this.fileServer, this.path,
      List<_WebToonImageProportionSize> sizeList, int indexOfSizeList)
      : super(sizeList, indexOfSizeList);

  @override
  Future<RemoteImageData> imageData() async {
    return pica.remoteImageData(fileServer, path);
  }
}

// 平铺到整个页面的图片
// 这个类是违背widget类@immutable装饰器的
// 将ReaderImage初始化到字段中, 而不是函数内变量中
// 从而避免因为listview滚动state重新初始化造成的画面抖动
abstract class _WebToonReaderImage extends StatefulWidget {
  final List<_WebToonImageProportionSize> sizeList;
  final int indexOfSizeList;

  _WebToonReaderImage(this.sizeList, this.indexOfSizeList);

  @override
  State<StatefulWidget> createState() => _WebToonReaderImageState();

  Future<RemoteImageData> imageData();
}

class _WebToonReaderImageState extends State<_WebToonReaderImage> {
  late Future<RemoteImageData> _future = widget.imageData().then((value) {
    widget.sizeList[widget.indexOfSizeList] =
        _WebToonImageProportionSize(value.width, value.height);
    return value;
  });

  // data.width/data.height = width/ ?
  // data.width * ? = width * data.height
  // ? = width * data.height / data.width
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        late double proportion =
            widget.sizeList[widget.indexOfSizeList].height /
                widget.sizeList[widget.indexOfSizeList].width;
        var width = constraints.maxWidth;
        return FutureBuilder(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot<RemoteImageData> snapshot,
          ) {
            if (snapshot.hasError) {
              return buildError(width, width * proportion);
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading(width, width * proportion);
            }
            // true size
            var data = snapshot.data!;
            var height = width * data.height / data.width;

            return GestureDetector(
              onLongPress: () async {
                String? choose = await chooseListDialog(context, '请选择', [
                  '预览图片',
                ]);
                switch (choose) {
                  case '预览图片':
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FilePhotoViewScreen(data.finalPath),
                    ));
                    break;
                }
              },
              child: Image.file(
                File(data.finalPath),
                width: width,
                height: height,
                errorBuilder: (a, b, c) => Container(
                  width: width,
                  height: height,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade400,
                      size: width / 2.5,
                    ),
                  ),
                ),
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonZoomReader extends _WebToonReader {
  _WebToonZoomReader(ImageReaderStruct struct) : super(struct);

  @override
  State<StatefulWidget> createState() => _WebToonZoomReaderState();
}

class _WebToonZoomReaderState extends _WebToonReaderState {
  @override
  Widget _buildList() {
    return InteractiveViewer(child: super._buildList());
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonPageReader extends StatefulWidget {
  final ImageReaderStruct struct;

  const _WebToonPageReader(this.struct);

  @override
  State<StatefulWidget> createState() => _WebToonPageReaderState();
}

class _WebToonPageReaderState extends State<_WebToonPageReader> {
  int _page = 0;
  int _pageSize = 10;
  late Future<List<_PageWebToonImageStatus>> _pageStatus = _initPage();

  void _prePage() {
    if (_page == 0) {
      return;
    }
    setState(() {
      _page--;
      _pageStatus = _initPage();
    });
  }

  void _nextPage() {
    if ((_page + 1) * _pageSize >= widget.struct.images.length) {
      return;
    }
    setState(() {
      _page++;
      _pageStatus = _initPage();
    });
  }

  Future<List<_PageWebToonImageStatus>> _initPage() async {
    await widget.struct.onPositionChange(_page * _pageSize);
    List<_PageWebToonImageStatus> list = [];
    var len = widget.struct.images.length;
    for (var index = _page * _pageSize;
        index < len && index < (_page + 1) * _pageSize;
        index++) {
      var item = widget.struct.images[index];
      if (item.localPath != null && item.localPath != "") {
        var status = _PageWebToonImageStatus();
        status.status = _ImageStatusSuccess;
        status.width = item.width!;
        status.height = item.height!;
        status.path = await pica.downloadImagePath(item.localPath!);
        list.add(status);
      } else {
        var status = _PageWebToonImageStatus();
        list.add(status);
        _downloadImage(
            list, index - (_page * _pageSize), item.fileServer, item.path);
      }
    }
    return list;
  }

  Future _downloadImage(List<_PageWebToonImageStatus> list, int index,
      String fileServer, String path) async {
    try {
      var data = await pica.remoteImageData(fileServer, path);
      setState(() {
        list[index].width = data.width;
        list[index].height = data.height;
        list[index].path = data.finalPath;
        list[index].status = _ImageStatusSuccess;
      });
    } catch (e) {
      setState(() {
        list[index].status = _ImageStatusError;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(
      future: _pageStatus,
      onRefresh: _initPage,
      successBuilder: (BuildContext context,
          AsyncSnapshot<List<_PageWebToonImageStatus>> snapshot) {
        return Stack(
          children: [
            GestureZoomBox(
              child: _buildViewer(snapshot.data!),
            ),
            ..._buildControllers(),
          ],
        );
      },
    );
  }

  Widget _buildViewer(List<_PageWebToonImageStatus> data) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var width = constraints.maxWidth;
        var height =
            data.map((e) => width * e.height / e.width).reduce((a, b) => a + b);
        return ListView(
          children: [
            Container(
              height: height,
              child: Column(
                children: data.map((e) {
                  switch (e.status) {
                    case _ImageStatusInit:
                      return LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          var width = constraints.maxWidth;
                          return buildLoading(
                              width, width * e.height / e.width);
                        },
                      );
                    case _ImageStatusError:
                      return LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          var width = constraints.maxWidth;
                          return buildError(width, width * e.height / e.width);
                        },
                      );
                    case _ImageStatusSuccess:
                      return LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          var width = constraints.maxWidth;

                          return GestureDetector(
                            onLongPress: () async {
                              String? choose = await chooseListDialog(
                                  context, '请选择', ['预览图片']);
                              switch (choose) {
                                case '预览图片':
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        FilePhotoViewScreen(e.path),
                                  ));
                                  break;
                              }
                            },
                            child: buildFile(
                                e.path, width, width * e.height / e.width),
                          );
                        },
                      );
                  }
                  return Container();
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildControllers() {
    if (widget.struct.fullScreen) {
      return [
        _buildFullScreenController(),
      ];
    }
    return [
      _buildFullScreenController(),
      _buildScrollController(),
    ];
  }

  Widget _buildFullScreenController() {
    return Container(
      child: Column(
        children: [
          Expanded(child: Container()),
          Row(
            children: [
              Material(
                color: Color(0x0),
                child: Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Color(0x88000000),
                  ),
                  margin: EdgeInsets.only(bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      widget.struct
                          .onFullScreenChange(!widget.struct.fullScreen);
                    },
                    child: Icon(
                      widget.struct.fullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollController() {
    if (widget.struct.images.length == 0) {
      return Container();
    }
    return Container(
      child: Row(
        children: [
          Expanded(child: Container()),
          Column(
            children: [
              Expanded(child: Container()),
              Material(
                color: Color(0x0),
                child: InkWell(
                  onTap: _prePage,
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 8),
                    child:
                        Text('上\n一\n页', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              Container(height: 10),
              Material(
                color: Color(0x0),
                child: InkWell(
                  onTap: _nextPage,
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 8),
                    child:
                        Text('下\n一\n页', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }
}

const _ImageStatusInit = 0;
const _ImageStatusSuccess = 1;
const _ImageStatusError = 2;

class _PageWebToonImageStatus {
  int status = _ImageStatusInit;
  int width = 2;
  int height = 1;
  late String path;
}
