// Editable_Image.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class CustomBoard extends StatefulWidget {
  const CustomBoard({super.key});

  @override
  CustomBoardState createState() => CustomBoardState();
}

class CustomBoardState extends State<CustomBoard> {
  final List<PlacedImage> _placedImages = [];
  int? _draggingIndex;
  Offset _dragOffset = Offset.zero;
  int? _selectedImageIndex;
  Offset? _startPoint;
  double? _startRotationAngle;
  Offset? _rotationCenter;
  String? _resizingHandleType;
  bool _showHandlers = false;

  // Minimum image size
  final double _minImageSize = 50.0;

  // Global position of the mouse cursor
  Offset _mousePosition = Offset.zero;
  // Local position of the mouse cursor
  Offset _localMousePosition = Offset.zero;

  String _customBoardText = ''; // CustomBoard에 표시할 텍스트

  @override
  void initState() {
    super.initState();
  }

  // 텍스트 업데이트 함수
  void updateText(String text) {
    setState(() {
      _customBoardText = text;
    });
  }

  void _addImage(String imagePath, Offset position) {
    final Image image = Image.asset(imagePath);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info.image);
        },
      ),
    );

    completer.future.then((ui.Image uiImage) {
      setState(() {
        _placedImages.add(PlacedImage(
          imagePath: imagePath,
          position: position,
          width: 100,
          height: 100 * (uiImage.height / uiImage.width),
          originalWidth: 100,
          originalHeight: 100 * (uiImage.height / uiImage.width),
          aspectRatio: uiImage.width / uiImage.height,
        ));
      });
    });
  }

  void _updateImagePosition(int index, Offset newPosition) {
    setState(() {
      _placedImages[index].position = newPosition - _dragOffset;
    });
  }

  void _startDragging(int index, Offset globalPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localImagePosition = renderBox.globalToLocal(globalPosition);
    setState(() {
      _draggingIndex = index;
      _dragOffset = localImagePosition - _placedImages[index].position;
    });
  }

  void _stopDragging() {
    setState(() {
      _draggingIndex = null;
      _dragOffset = Offset.zero;
    });
  }

  void _selectImage(int index) {
    setState(() {
      if (_selectedImageIndex == index) {
        _showHandlers = !_showHandlers;
      } else {
        _selectedImageIndex = index;
        _showHandlers = true;
      }
    });
  }

  void _startRotation(int index, DragStartDetails details) {
    setState(() {
      _selectedImageIndex = index;
      _showHandlers = true;
    });
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    _rotationCenter = _placedImages[index].position +
        Offset(_placedImages[index].width / 2,
            _placedImages[index].height / 2);
    _startRotationAngle = atan2(localPosition.dy - _rotationCenter!.dy,
        localPosition.dx - _rotationCenter!.dx);
  }

  void _updateRotation(int index, DragUpdateDetails details) {
    if (_rotationCenter != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      final currentRotationAngle = atan2(localPosition.dy - _rotationCenter!.dy,
          localPosition.dx - _rotationCenter!.dx);
      final angleDifference = currentRotationAngle - _startRotationAngle!;
      setState(() {
        _placedImages[index].rotationAngle += angleDifference;
        _startRotationAngle = currentRotationAngle;
      });
    }
  }

  void _handleResizeStart(int index, DragStartDetails details, String type) {
    setState(() {
      _selectedImageIndex = index;
      _showHandlers = true;
      _resizingHandleType = type;
    });
  }

  void _handleResizeUpdate(int index, DragUpdateDetails details, String type) {
    if (_selectedImageIndex == index) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      final PlacedImage image = _placedImages[index];

      // Convert local position to image's local coordinate system
      Offset imageLocalPosition = localPosition - image.position;

      // Rotate local position back to the original, unrotated coordinate system
      Offset rotatedImageLocalPosition = rotatePoint(
        imageLocalPosition,
        Offset(image.width / 2, image.height / 2),
        -image.rotationAngle,
      );

      // Get the fixed opposite point in the unrotated coordinate system
      Offset fixedPoint = getFixedOppositePointBasedOnType(type);

      // Limit the rotated local position to the opposite side of the fixed point
      rotatedImageLocalPosition = _limitPositionToOppositeSide(
          rotatedImageLocalPosition,
          fixedPoint,
          image.width,
          image.height);

      // Calculate new dimensions based on the rotated local position and fixed point
      double newWidth = image.width;
      double newHeight = image.height;
      Offset newPosition = image.position;

      switch (type) {
        case 'topLeft':
          newWidth =
              (rotatedImageLocalPosition.dx - image.width * fixedPoint.dx)
                  .abs();
          newHeight =
              (rotatedImageLocalPosition.dy - image.height * fixedPoint.dy)
                  .abs();
          newPosition = Offset(
            image.position.dx + (image.width - newWidth),
            image.position.dy + (image.height - newHeight),
          );
          break;

        case 'topCenter':
          newHeight =
              (rotatedImageLocalPosition.dy - image.height * fixedPoint.dy)
                  .abs();
          newPosition = Offset(
            image.position.dx,
            image.position.dy + (image.height - newHeight),
          );
          break;

        case 'topRight':
          newWidth = rotatedImageLocalPosition.dx;
          newHeight =
              (rotatedImageLocalPosition.dy - image.height * fixedPoint.dy)
                  .abs();
          newPosition = Offset(
            image.position.dx,
            image.position.dy + (image.height - newHeight),
          );
          break;

        case 'centerLeft':
          newWidth =
              (rotatedImageLocalPosition.dx - image.width * fixedPoint.dx)
                  .abs();
          newPosition = Offset(
            image.position.dx + (image.width - newWidth),
            image.position.dy,
          );
          break;

        case 'centerRight':
          newWidth = rotatedImageLocalPosition.dx;
          break;

        case 'bottomRight':
          newWidth = rotatedImageLocalPosition.dx;
          newHeight = rotatedImageLocalPosition.dy;
          break;

        case 'bottomCenter':
          newHeight = rotatedImageLocalPosition.dy;
          break;

        case 'bottomLeft':
          newWidth =
              (rotatedImageLocalPosition.dx - image.width * fixedPoint.dx)
                  .abs();
          newHeight = rotatedImageLocalPosition.dy;
          newPosition = Offset(
            image.position.dx + (image.width - newWidth),
            image.position.dy,
          );
          break;
      }

      // Ensure minimum size for the resizing direction
      if (newWidth < _minImageSize &&
          (type == 'topLeft' ||
              type == 'centerLeft' ||
              type == 'bottomLeft' ||
              type == 'topRight' ||
              type == 'centerRight' ||
              type == 'bottomRight')) {
        newWidth = _minImageSize;
      }
      if (newHeight < _minImageSize &&
          (type == 'topLeft' ||
              type == 'topCenter' ||
              type == 'topRight' ||
              type == 'bottomRight' ||
              type == 'bottomCenter' ||
              type == 'bottomLeft')) {
        newHeight = _minImageSize;
      }

      // Calculate the fixed point's global position after rotation
      Offset rotatedFixedPoint = rotatePoint(
        Offset(fixedPoint.dx * image.width, fixedPoint.dy * image.height),
        Offset(image.width / 2, image.height / 2),
        image.rotationAngle,
      );
      Offset fixedPointGlobal = image.position + rotatedFixedPoint;

      // Update image properties
      setState(() {
        image.width = newWidth;
        image.height = newHeight;
        image.position = newPosition;
      });

      // Adjust position to keep the fixed point at its original global position
      Offset newRotatedFixedPoint = rotatePoint(
        Offset(fixedPoint.dx * newWidth, fixedPoint.dy * newHeight),
        Offset(newWidth / 2, newHeight / 2),
        image.rotationAngle,
      );
      Offset newFixedPointGlobal = newPosition + newRotatedFixedPoint;
      Offset adjustment = fixedPointGlobal - newFixedPointGlobal;

      setState(() {
        image.position += adjustment;
      });
    }
  }

  // Helper function to limit the position to the opposite side of the fixed point
  Offset _limitPositionToOppositeSide(
      Offset position, Offset fixedPoint, double width, double height) {
    double x = position.dx;
    double y = position.dy;

    if (fixedPoint.dx == 0) {
      // Left side fixed
      if (x < 0) {
        x = 0;
      }
    } else if (fixedPoint.dx == 1) {
      // Right side fixed
      if (x > width) {
        x = width;
      }
    } else if (fixedPoint.dx == 0.5) {
      // Center horizontally fixed, no limit needed
    }

    if (fixedPoint.dy == 0) {
      // Top side fixed
      if (y < 0) {
        y = 0;
      }
    } else if (fixedPoint.dy == 1) {
      // Bottom side fixed
      if (y > height) {
        y = height;
      }
    } else if (fixedPoint.dy == 0.5) {
      // Center vertically fixed, no limit needed
    }

    return Offset(x, y);
  }

  // Helper function to get the fixed opposite point based on the handle type
  Offset getFixedOppositePointBasedOnType(String type) {
    switch (type) {
      case 'topLeft':
        return const Offset(1, 1); // Opposite of top-left is bottom-right
      case 'topCenter':
        return const Offset(0.5, 1); // Opposite of top-center is bottom-center
      case 'topRight':
        return const Offset(0, 1); // Opposite of top-right is bottom-left
      case 'centerLeft':
        return const Offset(1, 0.5); // Opposite of center-left is center-right
      case 'centerRight':
        return const Offset(0, 0.5); // Opposite of center-right is center-left
      case 'bottomRight':
        return const Offset(0, 0); // Opposite of bottom-right is top-left
      case 'bottomCenter':
        return const Offset(0.5, 0); // Opposite of bottom-center is top-center
      case 'bottomLeft':
        return const Offset(1, 0); // Opposite of bottom-left is top-right
      default:
        return Offset.zero;
    }
  }

  void _handleResizeEnd(int index, DragEndDetails details) {
    _resizingHandleType = null;
  }

  void _resetImageSize(int index) {
    setState(() {
      _placedImages[index].width = _placedImages[index].originalWidth;
      _placedImages[index].height = _placedImages[index].originalHeight;
    });
  }

  void _resetImageRotation(int index) {
    setState(() {
      _placedImages[index].rotationAngle = 0.0;
    });
  }

  void _deleteImage(int index) {
    setState(() {
      _placedImages.removeAt(index);
      _selectedImageIndex = null;
      _showHandlers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(event.position);
        setState(() {
          _mousePosition = event.position;
          if (_selectedImageIndex != null) {
            PlacedImage image = _placedImages[_selectedImageIndex!];
            // Convert local position to image's local coordinate system
            Offset imageLocalPosition = localPosition - image.position;
            // Rotate point back to the original, unrotated coordinate system for accurate calculations
            _localMousePosition = rotatePoint(
                imageLocalPosition,
                Offset(image.width / 2, image.height / 2),
                -image.rotationAngle);
          }
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedImageIndex = null;
            _showHandlers = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final Offset localPosition =
                    renderBox.globalToLocal(details.offset);
                _addImage(details.data, localPosition);
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (_placedImages.isEmpty)
                      const Center(
                        child: Placeholder(),
                      ),
                    ..._placedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final placedImage = entry.value;

                      return Positioned(
                        left: placedImage.position.dx,
                        top: placedImage.position.dy,
                        // GestureDetector를 Transform.rotate로 감싸서 회전 적용
                        child: Transform.rotate(
                          angle: placedImage.rotationAngle,
                          child: GestureDetector(
                            onTap: () => _selectImage(index),
                            onPanStart: (details) =>
                                _startDragging(index, details.globalPosition),
                            onPanUpdate: (details) {
                              if (_draggingIndex == index) {
                                final RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                final Offset localPosition =
                                    renderBox.globalToLocal(
                                        details.globalPosition);
                                _updateImagePosition(index, localPosition);
                              }
                            },
                            onPanEnd: (_) => _stopDragging(),
                            child: SizedBox(
                              width: placedImage.width,
                              height: placedImage.height,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                  child: Image.asset(
                                    placedImage.imagePath,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_selectedImageIndex != null && _showHandlers)
                      _buildImageHandlers(_placedImages[_selectedImageIndex!]),
                    if (_selectedImageIndex != null && _showHandlers)
                      _buildControlButtons(
                          _placedImages[_selectedImageIndex!],
                          _selectedImageIndex!),
                    if (_selectedImageIndex != null && _showHandlers)
                      _buildRotationIcon(_placedImages[_selectedImageIndex!]),
                  ],
                );
              },
            ),
            // Display mouse positions
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Global: ${_mousePosition.dx.toStringAsFixed(0)}, ${_mousePosition.dy.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.black, backgroundColor: Colors.white),
                  ),
                  if (_selectedImageIndex != null)
                    Text(
                      'Local: ${_localMousePosition.dx.toStringAsFixed(0)}, ${_localMousePosition.dy.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.black, backgroundColor: Colors.white),
                    ),
                ],
              ),
            ),
            // 텍스트 표시
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _customBoardText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            // IgnorePointer를 Stack 바깥으로 이동하고, 그 안에 Positioned 위젯을 배치
            IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 0, // 높이를 0으로 설정하여 텍스트 표시에 영향을 주지 않음
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(PlacedImage image, int index) {
    const buttonSize = 30.0;
    const offset = 10.0;
    const verticalOffset = 50.0; // 버튼 겹침 방지를 위한 추가 오프셋
    final centerX = image.position.dx + image.width / 2;
    final centerY = image.position.dy + image.height / 2;
    final rotationIconRadius = image.height / 2 + 50;

    final rotationIconX = centerX + rotationIconRadius * cos(-pi / 2);
    final rotationIconY = centerY + rotationIconRadius * sin(-pi / 2);

    return Positioned(
      left: rotationIconX -
          buttonSize * 1.5 -
          offset +
          10, // Row를 사용하기 때문에 전체 너비를 고려하여 left 조정
      top: rotationIconY - buttonSize / 2 - verticalOffset,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Row의 크기를 내용물에 맞게 조정
        children: [
          ElevatedButton(
            onPressed: () => _resetImageRotation(index),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: Size(buttonSize, buttonSize),
            ),
            child: const Icon(Icons.rotate_left, size: 25),
          ),
          SizedBox(width: offset), // 버튼 사이 간격
          ElevatedButton(
            onPressed: () => _resetImageSize(index),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: Size(buttonSize, buttonSize),
            ),
            child: const Icon(Icons.restore, size: 25),
          ),
          SizedBox(width: offset), // 버튼 사이 간격
          ElevatedButton(
            onPressed: () => _deleteImage(index),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              minimumSize: Size(buttonSize, buttonSize),
              backgroundColor: Colors.red,
            ),
            child: const Icon(Icons.delete, size: 25, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHandlers(PlacedImage image) {
    const handleSize = 20.0;
    final halfSize = handleSize / 2;
    final centerX = image.position.dx + image.width / 2;
    final centerY = image.position.dy + image.height / 2;

    Offset rotatePoint(Offset point, Offset center, double angle) {
      final double translateX = point.dx - center.dx;
      final double translateY = point.dy - center.dy;
      final double rotatedX = translateX * cos(angle) - translateY * sin(angle);
      final double rotatedY = translateX * sin(angle) + translateY * cos(angle);
      return Offset(center.dx + rotatedX, center.dy + rotatedY);
    }

    final topLeft =
        rotatePoint(image.position, Offset(centerX, centerY), image.rotationAngle);
    final topCenter = rotatePoint(
        Offset(image.position.dx + image.width / 2, image.position.dy),
        Offset(centerX, centerY),
        image.rotationAngle);
    final topRight = rotatePoint(
        Offset(image.position.dx + image.width, image.position.dy),
        Offset(centerX, centerY),
        image.rotationAngle);
    final centerLeft = rotatePoint(
        Offset(image.position.dx, image.position.dy + image.height / 2),
        Offset(centerX, centerY),
        image.rotationAngle);
    final centerRight = rotatePoint(
        Offset(image.position.dx + image.width,
            image.position.dy + image.height / 2),
        Offset(centerX, centerY),
        image.rotationAngle);
    final bottomLeft = rotatePoint(
        Offset(image.position.dx, image.position.dy + image.height),
        Offset(centerX, centerY),
        image.rotationAngle);
    final bottomCenter = rotatePoint(
        Offset(image.position.dx + image.width / 2,
            image.position.dy + image.height),
        Offset(centerX, centerY),
        image.rotationAngle);
    final bottomRight = rotatePoint(
        Offset(image.position.dx + image.width,
            image.position.dy + image.height),
        Offset(centerX, centerY),
        image.rotationAngle);

    return Stack(
      children: [
        _buildResizeHandle(topLeft.dx - halfSize, topLeft.dy - halfSize, 'topLeft'),
        _buildResizeHandle(
            topCenter.dx - halfSize, topCenter.dy - halfSize, 'topCenter'),
        _buildResizeHandle(
            topRight.dx - halfSize, topRight.dy - halfSize, 'topRight'),
        _buildResizeHandle(
            centerLeft.dx - halfSize, centerLeft.dy - halfSize, 'centerLeft'),
        _buildResizeHandle(
            centerRight.dx - halfSize, centerRight.dy - halfSize, 'centerRight'),
        _buildResizeHandle(
            bottomLeft.dx - halfSize, bottomLeft.dy - halfSize, 'bottomLeft'),
        _buildResizeHandle(
            bottomCenter.dx - halfSize, bottomCenter.dy - halfSize, 'bottomCenter'),
        _buildResizeHandle(
            bottomRight.dx - halfSize, bottomRight.dy - halfSize, 'bottomRight'),
      ],
    );
  }

  Widget _buildResizeHandle(double left, double top, String type) {
    const handleSize = 20.0;
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanStart: (details) =>
            _handleResizeStart(_selectedImageIndex!, details, type),
        onPanUpdate: (details) =>
            _handleResizeUpdate(_selectedImageIndex!, details, type),
        onPanEnd: (details) => _handleResizeEnd(_selectedImageIndex!, details),
        child: MouseRegion(
          cursor: getCursorForHandle(type),
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(handleSize / 2),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  SystemMouseCursor getCursorForHandle(String type) {
    switch (type) {
      case 'topLeft':
        return SystemMouseCursors.grab;
      case 'bottomRight':
        return SystemMouseCursors.grab;
      case 'topRight':
        return SystemMouseCursors.grab;
      case 'bottomLeft':
        return SystemMouseCursors.grab;
      case 'topCenter':
      case 'bottomCenter':
        return SystemMouseCursors.grab;
      case 'centerLeft':
      case 'centerRight':
        return SystemMouseCursors.grab;
      default:
        return SystemMouseCursors.basic;
    }
  }

  Widget _buildRotationIcon(PlacedImage image) {
    const iconSize = 30.0;
    final centerX = image.position.dx + image.width / 2;
    final centerY = image.position.dy + image.height / 2;
    final rotationIconRadius = image.height / 2 + 50;

    return Positioned(
      left: centerX +
          rotationIconRadius * cos(image.rotationAngle - pi / 2) -
          iconSize / 2,
      top: centerY +
          rotationIconRadius * sin(image.rotationAngle - pi / 2) -
          iconSize / 2,
      child: GestureDetector(
        onPanStart: (details) => _startRotation(_selectedImageIndex!, details),
        onPanUpdate: (details) => _updateRotation(_selectedImageIndex!, details),
        child: Icon(Icons.rotate_right, size: iconSize, color: Colors.black87),
      ),
    );
  }
}

class PlacedImage {
  final String imagePath;
  Offset position;
  double rotationAngle;
  double width;
  double height;
  final double aspectRatio;
  final double originalWidth;
  final double originalHeight;

  PlacedImage({
    required this.imagePath,
    required this.position,
    this.rotationAngle = 0.0,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.originalWidth,
    required this.originalHeight,
  });
}

// Helper function to rotate a point around a center
Offset rotatePoint(Offset point, Offset center, double angle) {
  final double translateX = point.dx - center.dx;
  final double translateY = point.dy - center.dy;
  final double rotatedX = translateX * cos(angle) - translateY * sin(angle);
  final double rotatedY = translateX * sin(angle) + translateY * cos(angle);
  return Offset(center.dx + rotatedX, center.dy + rotatedY);
}