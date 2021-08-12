import 'dart:io';

import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/enum/PagerType.dart';
import 'package:pikapi/screens/components/ContentBuilder.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:zoom_widget/zoom_widget.dart';

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
  final Function(bool fullScreen) onFullScreenChange;
  final Function() onNextEp;
  final Function(int) onPositionChange;
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
            return _WebToonImageReader(widget.struct);
          case PagerType.PAGE_WEB_TOON:
            return _PageWebToonImageReader(widget.struct);
          default:
            return Container();
        }
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonImageReader extends StatefulWidget {
  final ImageReaderStruct struct;

  const _WebToonImageReader(this.struct);

  @override
  State<StatefulWidget> createState() => _WebToonImageReaderState();
}

class _WebToonImageReaderState extends State<_WebToonImageReader> {
  late final List<Widget> images = [];
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;
  late final int _initialPosition;

  var current = 1;
  var slider = 1;

  @override
  void initState() {
    images.addAll(widget.struct.images.map((e) {
      if (e.localPath != null) {
        return _DownloadReaderImage(
          e.fileServer,
          e.path,
          e.localPath!,
          e.fileSize!,
          e.width!,
          e.height!,
          e.format!,
        );
      } else {
        return _RemoteReaderImage(e.fileServer, e.path);
      }
    }).toList());
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

  void _onCurrentChange() {
    var to = _itemPositionsListener.itemPositions.value.first.index + 1;
    if (current != to) {
      setState(() {
        current = to;
        slider = to;
        if (to - 1 < widget.struct.images.length) {
          widget.struct.onPositionChange(to - 1);
        }
      });
    }
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
        return images[index];
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
                    (slider > widget.struct.images.length
                            ? widget.struct.images.length
                            : slider)
                        .toDouble()
                  ],
                  max: widget.struct.images.length.toDouble(),
                  min: 1,
                  onDragging: (handlerIndex, lowerValue, upperValue) {
                    double a = lowerValue;
                    slider = a.toInt();
                  },
                  onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                    if (slider != current && slider > 0) {
                      _itemScrollController.jumpTo(index: slider - 1);
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
class _DownloadReaderImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;
  final String localPath;
  final int fileSize;
  final int width;
  final int height;
  final String format;

  _DownloadReaderImage(this.fileServer, this.path, this.localPath,
      this.fileSize, this.width, this.height, this.format);

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

// 来自远端
class _RemoteReaderImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;

  _RemoteReaderImage(this.fileServer, this.path);

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
  double? proportionWidth;
  double? proportionHeight;

  _WebToonReaderImage({Key? key, this.proportionWidth, this.proportionHeight})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebToonReaderImageState();

  Future<RemoteImageData> imageData();
}

class _WebToonReaderImageState extends State<_WebToonReaderImage> {
  late Future<RemoteImageData> _future = widget.imageData().then((value) {
    widget.proportionWidth = value.width.toDouble();
    widget.proportionHeight = value.height.toDouble();
    return value;
  });

  // data.width/data.height = width/ ?
  // data.width * ? = width * data.height
  // ? = width * data.height / data.width
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        late double proportion;
        if (widget.proportionWidth != null && widget.proportionHeight != null) {
          proportion = widget.proportionHeight! / widget.proportionWidth!;
        } else {
          proportion = .5;
        }
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
            return Image.file(
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
            );
          },
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _PageWebToonImageReader extends StatefulWidget {
  final ImageReaderStruct struct;

  const _PageWebToonImageReader(this.struct);

  @override
  State<StatefulWidget> createState() => _PageWebToonImageReaderState();
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

class _PageWebToonImageReaderState extends State<_PageWebToonImageReader> {
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
    if ((_page + 1) * _pageSize >= widget.struct.images.length){
      return;
    }
    setState(() {
      _page++;
      _pageStatus = _initPage();
    });
  }

  Future<List<_PageWebToonImageStatus>> _initPage() async {
    List<_PageWebToonImageStatus> list = [];
    var len = widget.struct.images.length;
    for (var index = _page * _pageSize;
        index < len && index < (_page + 1) * _pageSize;
        index++) {
      var item = widget.struct.images[index];
      if (item.localPath != null) {
        var status = _PageWebToonImageStatus();
        status.status = _ImageStatusSuccess;
        status.width = item.width!;
        status.height = item.height!;
        status.path = await pica.downloadImagePath(item.path);
        list.add(status);
      } else {
        var status = _PageWebToonImageStatus();
        list.add(status);
        _downloadImage(list, index - (_page * _pageSize), item.fileServer, item.path);
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
            _buildViewer(snapshot.data!),
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
        return Zoom(
          initZoom: 0,
          maxZoomWidth: width * 2,
          maxZoomHeight: height * 2,
          centerOnScale: false,
          child: Container(
            child: Column(
              children: data.map((e) {
                switch (e.status) {
                  case _ImageStatusInit:
                    return LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        var width = constraints.maxWidth;
                        return buildLoading(width, width * e.height / e.width);
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
                        return buildFile(
                            e.path, width, width * e.height / e.width);
                      },
                    );
                }
                return Container();
              }).toList(),
            ),
          ),
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
