import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ImageReader extends StatefulWidget {
  final List<Widget> images;
  final bool fullScreen;
  final void Function(bool fullScreen) onFullScreenChange;
  final void Function() onNextEp;
  final void Function(int) onPositionChange;
  final int? initPosition;

  const ImageReader({
    Key? key,
    required this.images,
    required this.fullScreen,
    required this.onFullScreenChange,
    required this.onNextEp,
    required this.onPositionChange,
    this.initPosition,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageReaderState();
}

class _ImageReaderState extends State<ImageReader> {
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;
  late final int _initialPosition;

  var current = 1;
  var slider = 1;

  @override
  void initState() {
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onCurrentChange);
    if (widget.initPosition != null &&
        widget.images.length > widget.initPosition!) {
      _initialPosition = widget.initPosition!;
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
        widget.onPositionChange(to);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold.of(context);
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          ScrollablePositionedList.builder(
            initialScrollIndex: _initialPosition,
            padding: widget.fullScreen
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
              return widget.images[index];
            },
          ),
          ..._buildControllers(),
        ],
      ),
    );
  }

  List<Widget> _buildControllers() {
    if (widget.fullScreen) {
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
                      widget.onFullScreenChange(!widget.fullScreen);
                    },
                    child: Icon(
                      widget.fullScreen
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
    if (widget.images.length == 0) {
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
                    (slider > widget.images.length
                            ? widget.images.length
                            : slider)
                        .toDouble()
                  ],
                  max: widget.images.length.toDouble(),
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
                      color: theme.accentColor,
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
        onPressed: widget.onNextEp,
        textColor: Colors.white,
        child: Container(
          padding: EdgeInsets.only(top: 40, bottom: 40),
          child: Text("下一章"),
        ),
      ),
    );
  }
}
