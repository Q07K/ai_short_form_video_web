// resizablewidget.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ResizebleWidget extends StatefulWidget {
  ResizebleWidget({this.imagePath, this.initialTop, this.initialLeft, Key? key}) : super(key: key);

  final String? imagePath;
  final double? initialTop;
  final double? initialLeft;

  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

const ballDiameter = 20.0; // 핸들 크기를 키워서 터치 영역 확보

class _ResizebleWidgetState extends State<ResizebleWidget> {
  double width = 100; // 고정 너비
  double height = 100; // 초기 높이
  bool _showHandlers = false;
  final double _handlerPadding = 20.0; // 핸들러와 이미지 사이 간격

  double top = 0;
  double left = 0;

  double initX = 0;
  double initY = 0;

  @override
  void initState() {
    super.initState();
    top = widget.initialTop ?? 0;
    left = widget.initialLeft ?? 0;
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    if (widget.imagePath != null) {
      final image = AssetImage(widget.imagePath!);
      final ImageStream stream = image.resolve(ImageConfiguration.empty);
      stream.addListener(
        ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
          setState(() {
            height = width * imageInfo.image.height / imageInfo.image.width;
          });
        }),
      );
    }
  }

  _handleImageDragStart(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleImageDragUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    setState(() {
      top = top + dy;
      left = left + dx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Stack(
        children: <Widget>[
          // 이미지 Container with Drag Gesture 분리
          Container(
            height: height + _handlerPadding * 2, // 패딩을 고려한 전체 높이
            width: width + _handlerPadding * 2, // 패딩을 고려한 전체 너비
            decoration: BoxDecoration(
              // 핸들러가 보일 때만 테두리 표시
              border: Border.all(
                width: 1,
                color: _showHandlers ? Colors.lightBlue : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(_handlerPadding),
              child: GestureDetector( // GestureDetector를 이미지 영역으로 이동
                onPanStart: _handleImageDragStart,
                onPanUpdate: _handleImageDragUpdate,
                onTap: () {
                  setState(() {
                    _showHandlers = !_showHandlers;
                  });
                },
                child: SizedBox( //SizedBox로 명시적인 크기 지정
                  width: width,
                  height: height,
                  child: widget.imagePath != null
                      ? Image.asset(
                          widget.imagePath!,
                          fit: BoxFit.fill,
                        )
                      : Container(),
                ),
              ),
            ),
          ),
          // 드래그 핸들 Positioned 위젯들을 Stack 위쪽으로 이동
          if (_showHandlers) ...[
            // top left
            Positioned(
              top: 0,
              left: 0,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = height - dy;
                  var newWidth = width - dx;

                  setState(() {
                    height = newHeight > 0 ? newHeight : 0;
                    width = newWidth > 0 ? newWidth : 0;
                    top = top + dy;
                    left = left + dx;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            // top middle
            Positioned(
              top: 0,
              left: width / 2 - ballDiameter / 2 + _handlerPadding,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = height - dy;

                  setState(() {
                    height = newHeight > 0 ? newHeight : 0;
                    top = top + dy;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            // top right
            Positioned(
              top: 0,
              left: width - ballDiameter + _handlerPadding * 2,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = height - dy;
                  var newWidth = width + dx;

                  setState(() {
                    height = newHeight > 0 ? newHeight : 0;
                    width = newWidth > 0 ? newWidth : 0;
                    top = top + dy;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            // center right
            Positioned(
              top: height / 2 - ballDiameter / 2 + _handlerPadding,
              left: width - ballDiameter + _handlerPadding * 2,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newWidth = width + dx;

                  setState(() {
                    width = newWidth > 0 ? newWidth : 0;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            // bottom right
            Positioned(
              top: height - ballDiameter + _handlerPadding * 2,
              left: width - ballDiameter + _handlerPadding * 2,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = height + dy;
                  var newWidth = width + dx;

                  setState(() {
                    height = newHeight > 0 ? newHeight : 0;
                    width = newWidth > 0 ? newWidth : 0;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            // bottom center
            Positioned(
              top: height - ballDiameter + _handlerPadding * 2,
              left: width / 2 - ballDiameter / 2 + _handlerPadding,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = height + dy;

                  setState(() {
                    height = newHeight > 0 ? newHeight : 0;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            // bottom left
            Positioned(
              top: height - ballDiameter + _handlerPadding * 2,
              left: 0,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newHeight = height + dy;
                  var newWidth = width - dx;

                  setState(() {
                    height = newHeight > 0 ? newHeight : 0;
                    width = newWidth > 0 ? newWidth : 0;
                    left = left + dx;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
            //left center
            Positioned(
              top: height / 2 - ballDiameter / 2 + _handlerPadding,
              left: 0,
              child: ManipulatingBall(
                onDrag: (dx, dy) {
                  var newWidth = width - dx;

                  setState(() {
                    width = newWidth > 0 ? newWidth : 0;
                    left = left + dx;
                  });
                },
                handlerWidget: HandlerWidget.SQUARE,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({this.onDrag, this.handlerWidget});

  final Function(double dx, double dy)? onDrag;
  final HandlerWidget? handlerWidget;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

enum HandlerWidget { SQUARE }

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX = 0;
  double initY = 0;

  _handleDragStart(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleDragUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag?.call(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
    );
  }
}