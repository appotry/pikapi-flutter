import 'dart:async';

import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Cross.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'package:pikapi/basic/config/FullScreenAction.dart';
import 'package:pikapi/basic/config/ReaderDirection.dart';
import 'package:pikapi/basic/config/ReaderType.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../FilePhotoViewScreen.dart';
import 'gesture_zoom_box.dart';

import 'Images.dart';

///////////////////////////////////////////////////////////////////////////////

// 对Reader的传参以及封装

class ReaderImageInfo {
  final String fileServer;
  final String path;
  final String? downloadLocalPath;
  final int? width;
  final int? height;
  final String? format;
  final int? fileSize;

  ReaderImageInfo(this.fileServer, this.path, this.downloadLocalPath,
      this.width, this.height, this.format, this.fileSize);
}

class ImageReaderStruct {
  final bool fullScreen;
  final FutureOr<dynamic> Function(bool fullScreen) onFullScreenChange;
  final FutureOr<dynamic> Function() onNextEp;
  final FutureOr<dynamic> Function(int) onPositionChange;
  final int? initPosition;
  final ReaderType pagerType;
  final ReaderDirection pagerDirection;

  const ImageReaderStruct({
    required this.fullScreen,
    required this.onFullScreenChange,
    required this.onNextEp,
    required this.onPositionChange,
    this.initPosition,
    required this.pagerType,
    required this.pagerDirection,
  });
}

class ImageReader extends StatelessWidget {
  final List<ReaderImageInfo> images;
  final ImageReaderStruct struct;

  const ImageReader(this.images, this.struct);

  @override
  Widget build(BuildContext context) {
    late Widget reader;
    switch (struct.pagerType) {
      case ReaderType.WEB_TOON:
        reader = _WebToonReader(images, struct);
        break;
      case ReaderType.WEB_TOON_ZOOM:
        reader = _WebToonZoomReader(images, struct);
        break;
      case ReaderType.GALLERY:
        reader = _GalleryReader(images, struct);
        break;
      default:
        reader = Container();
        break;
    }
    switch (fullScreenAction) {
      case FullScreenAction.CONTROLLER:
        return Stack(
          children: [
            reader,
            _buildFullScreenController(
              struct.fullScreen,
              struct.onFullScreenChange,
            ),
          ],
        );
      case FullScreenAction.TOUCH_ONCE:
        return GestureDetector(
          onTap: () => struct.onFullScreenChange(!struct.fullScreen),
          child: reader,
        );
      default:
        return reader;
    }
  }

  Widget _buildFullScreenController(
    bool fullScreen,
    FutureOr<dynamic> Function(bool fullScreen) onFullScreenChange,
  ) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        color: Color(0x0),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Color(0x88000000),
          ),
          child: GestureDetector(
            onTap: () {
              onFullScreenChange(!fullScreen);
            },
            child: Icon(
              fullScreen ? Icons.fullscreen_exit : Icons.fullscreen_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class _WebToonReader extends StatefulWidget {
  final List<ReaderImageInfo> images;
  final ImageReaderStruct struct;

  const _WebToonReader(this.images, this.struct);

  @override
  State<StatefulWidget> createState() => _WebToonReaderState();
}

class _WebToonReaderState extends State<_WebToonReader> {
  late final List<Size?> _trueSizes = [];
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
        if (to - 1 < widget.images.length) {
          widget.struct.onPositionChange(to - 1);
        }
      });
    }
  }

  @override
  void initState() {
    widget.images.forEach((e) {
      if (e.downloadLocalPath != null) {
        _trueSizes.add(Size(e.width!.toDouble(), e.height!.toDouble()));
      } else {
        _trueSizes.add(null);
      }
    });
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onCurrentChange);
    if (widget.struct.initPosition != null &&
        widget.images.length > widget.struct.initPosition!) {
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // reload _images size
        List<Widget> _images = [];
        for (var index = 0; index < widget.images.length; index++) {
          late Size renderSize;
          if (_trueSizes[index] != null) {
            if (widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM) {
              renderSize = Size(
                constraints.maxWidth,
                constraints.maxWidth *
                    _trueSizes[index]!.height /
                    _trueSizes[index]!.width,
              );
            } else {
              renderSize = Size(
                constraints.maxHeight *
                    _trueSizes[index]!.width /
                    _trueSizes[index]!.height,
                constraints.maxHeight,
              );
            }
          } else {
            if (widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM) {
              renderSize = Size(constraints.maxWidth, constraints.maxWidth / 2);
            } else {
              // ReaderDirection.LEFT_TO_RIGHT
              // ReaderDirection.RIGHT_TO_LEFT
              renderSize =
                  Size(constraints.maxWidth / 2, constraints.maxHeight);
            }
          }
          var currentIndex = index;
          var onTrueSize = (Size size) {
            setState(() {
              _trueSizes[currentIndex] = size;
            });
          };
          var e = widget.images[index];
          if (e.downloadLocalPath != null) {
            _images.add(_WebToonDownloadImage(
              fileServer: e.fileServer,
              path: e.path,
              localPath: e.downloadLocalPath!,
              fileSize: e.fileSize!,
              width: e.width!,
              height: e.height!,
              format: e.format!,
              size: renderSize,
              onTrueSize: onTrueSize,
            ));
          } else {
            _images.add(_WebToonRemoteImage(
              e.fileServer,
              e.path,
              renderSize,
              onTrueSize,
            ));
          }
        }
        return ScrollablePositionedList.builder(
          initialScrollIndex: _initialPosition,
          scrollDirection:
              widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM
                  ? Axis.vertical
                  : Axis.horizontal,
          reverse:
              widget.struct.pagerDirection == ReaderDirection.RIGHT_TO_LEFT,
          padding: widget.struct.fullScreen
              ? EdgeInsets.only(
                  top: scaffold.appBarMaxHeight ?? 0,
                  bottom: scaffold.appBarMaxHeight ?? 0,
                )
              : null,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: widget.images.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (widget.images.length == index) {
              return _buildNextEp();
            }
            return _images[index];
          },
        );
      },
    );
  }

  List<Widget> _buildControllers() {
    if (widget.struct.fullScreen) {
      return [];
    }
    return [
      _buildImageCount(context, "$_current / ${widget.images.length}"),
      _buildScrollController(
        context,
        _current,
        _slider,
        widget.images.length,
        (value) => _slider = value,
        () {
          if (_slider != _current && _slider > 0) {
            _itemScrollController.jumpTo(index: _slider - 1);
          }
        },
      ),
    ];
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
    required Size size,
    Function(Size)? onTrueSize,
  }) : super(size, onTrueSize);

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
class _WebToonRemoteImage extends _WebToonReaderImage {
  final String fileServer;
  final String path;

  _WebToonRemoteImage(
    this.fileServer,
    this.path,
    Size size,
    Function(Size)? onTrueSize,
  ) : super(size, onTrueSize);

  @override
  Future<RemoteImageData> imageData() async {
    return pica.remoteImageData(fileServer, path);
  }
}

// 通用
abstract class _WebToonReaderImage extends StatefulWidget {
  final Size size;
  final Function(Size)? onTrueSize;

  _WebToonReaderImage(this.size, this.onTrueSize);

  @override
  State<StatefulWidget> createState() => _WebToonReaderImageState();

  Future<RemoteImageData> imageData();
}

class _WebToonReaderImageState extends State<_WebToonReaderImage> {
  late Future<RemoteImageData> _future = _load();

  Future<RemoteImageData> _load() {
    return widget.imageData().then((value) {
      widget.onTrueSize?.call(
        Size(value.width.toDouble(), value.height.toDouble()),
      );
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FutureBuilder(
          future: _future,
          builder: (
            BuildContext context,
            AsyncSnapshot<RemoteImageData> snapshot,
          ) {
            if (snapshot.hasError) {
              return GestureDetector(
                onLongPress: () async {
                  String? choose =
                      await chooseListDialog(context, '请选择', ['重新加载图片']);
                  switch (choose) {
                    case '重新加载图片':
                      setState(() {
                        _future = _load();
                      });
                      break;
                  }
                },
                child: buildError(widget.size.width, widget.size.height),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return buildLoading(widget.size.width, widget.size.height);
            }
            var data = snapshot.data!;
            return GestureDetector(
              onLongPress: () async {
                String? choose =
                    await chooseListDialog(context, '请选择', ['预览图片', '保存图片']);
                switch (choose) {
                  case '预览图片':
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FilePhotoViewScreen(data.finalPath),
                    ));
                    break;
                  case '保存图片':
                    saveImage(data.finalPath, context);
                    break;
                }
              },
              child: buildFile(
                data.finalPath,
                widget.size.width,
                widget.size.height,
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
  const _WebToonZoomReader(
    List<ReaderImageInfo> images,
    ImageReaderStruct struct,
  ) : super(images, struct);

  @override
  State<StatefulWidget> createState() => _WebToonZoomReaderState();
}

class _WebToonZoomReaderState extends _WebToonReaderState {
  @override
  Widget _buildList() {
    return GestureZoomBox(child: super._buildList());
  }
}

///////////////////////////////////////////////////////////////////////////////

class _GalleryReader extends StatefulWidget {
  final List<ReaderImageInfo> images;
  final ImageReaderStruct struct;

  _GalleryReader(this.images, this.struct);

  @override
  State<StatefulWidget> createState() => _GalleryReaderState();
}

class _GalleryReaderState extends State<_GalleryReader> {
  late int _current = (widget.struct.initPosition ?? 0) + 1;
  late int _slider = (widget.struct.initPosition ?? 0) + 1;
  late PageController _pageController =
      PageController(initialPage: widget.struct.initPosition ?? 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildViewer(),
        ..._buildControllers(),
      ],
    );
  }

  Widget _buildViewer() {
    return PhotoViewGallery.builder(
      scrollDirection:
          widget.struct.pagerDirection == ReaderDirection.TOP_TO_BOTTOM
              ? Axis.vertical
              : Axis.horizontal,
      reverse: widget.struct.pagerDirection == ReaderDirection.RIGHT_TO_LEFT,
      backgroundDecoration: BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return buildLoading(constraints.maxWidth, constraints.maxHeight);
        },
      ),
      pageController: _pageController,
      onPageChanged: (value) {
        setState(() {
          _current = value + 1;
          _slider = value + 1;
          widget.struct.onPositionChange(value);
        });
      },
      itemCount: widget.images.length,
      builder: (BuildContext context, int index) {
        var item = widget.images[index];
        if (item.downloadLocalPath != null) {
          return PhotoViewGalleryPageOptions(
            imageProvider:
                PicaDownloadFileImageProvider(item.downloadLocalPath!),
            errorBuilder: (b, e, s) {
              print("$e,$s");
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return buildError(
                      constraints.maxWidth, constraints.maxHeight);
                },
              );
            },
          );
        }
        return PhotoViewGalleryPageOptions(
          imageProvider: PicaRemoteImageProvider(item.fileServer, item.path),
          errorBuilder: (b, e, s) {
            print("$e,$s");
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return buildError(constraints.maxWidth, constraints.maxHeight);
              },
            );
          },
        );
      },
    );
  }

  List<Widget> _buildControllers() {
    var controllers = <Widget>[];
    if (!widget.struct.fullScreen) {
      controllers.addAll([
        _buildImageCount(context, "$_current / ${widget.images.length}"),
        _buildScrollController(
          context,
          _current,
          _slider,
          widget.images.length,
          (value) => _slider = value,
          () {
            if (_slider != _current && _slider > 0) {
              _pageController.jumpToPage(_slider - 1);
            }
          },
        ),
      ]);
    }
    if (_current == widget.images.length) {
      controllers.add(_buildNextEpController(widget.struct.onNextEp));
    }
    return controllers;
  }
}

///////////////////////////////////////////////////////////////////////////////

Widget _buildImageCount(BuildContext context, String info) {
  return Align(
    alignment: Alignment.topRight,
    child: Material(
      color: Color(0x0),
      child: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          color: Color(0x88000000),
        ),
        child: GestureDetector(
          onTap: () {
            // TODO 输入跳转页数
          },
          child: Text("$info", style: TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
}

Widget _buildScrollController(
  BuildContext context,
  int current,
  int slider,
  int total,
  Function(int) onSliderChange,
  Function() onSliderDown,
) {
  if (total == 0) {
    return Container();
  }
  var theme = Theme.of(context);
  return Align(
    alignment: Alignment.centerRight,
    child: Material(
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
            values: [(slider > total ? total : slider).toDouble()],
            max: total.toDouble(),
            min: 1,
            onDragging: (handlerIndex, lowerValue, upperValue) {
              onSliderChange(lowerValue.toInt());
            },
            onDragCompleted: (handlerIndex, lowerValue, upperValue) {
              onSliderChange(lowerValue.toInt());
              onSliderDown();
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
                child:
                    Text('${a.toInt()}', style: TextStyle(color: Colors.black)),
              );
            }),
          ),
        ),
      ),
    ),
  );
}

Widget _buildNextEpController(Function() next) {
  return Align(
    alignment: Alignment.bottomRight,
    child: Material(
      color: Color(0x0),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          color: Color(0x88000000),
        ),
        child: GestureDetector(
          onTap: () {
            next();
          },
          child: Text("下一章", style: TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
}
