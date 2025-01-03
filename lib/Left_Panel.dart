// leftpanel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'resizablewidget.dart'; // ResizableWidget 임포트

class LeftPanel extends StatefulWidget {
  const LeftPanel({super.key});

  @override
  _LeftPanelState createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const CustomBoard(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const ImageGallery(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBoard extends StatefulWidget {
  const CustomBoard({super.key});

  @override
  _CustomBoardState createState() => _CustomBoardState();
}

class _CustomBoardState extends State<CustomBoard> {
  final List<Widget> _placedWidgets = []; // PlacedImage 대신 ResizableWidget 사용

  void _addImage(String imagePath, Offset position) {
    setState(() {
      _placedWidgets.add(
        ResizebleWidget(
          imagePath: imagePath,
          initialTop: position.dy,
          initialLeft: position.dx,
          key: UniqueKey(), // 각 위젯에 고유 키 제공
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localPosition = renderBox.globalToLocal(details.offset);
        _addImage(details.data, localPosition);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            if (_placedWidgets.isEmpty)
              const Center(
                child: Placeholder(),
              ),
            ..._placedWidgets.map((widget) => widget).toList(),
          ],
        );
      },
    );
  }
}

class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadAssetImages();
  }

  Future<void> _loadAssetImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = await json.decode(manifestContent);

    setState(() {
      _imagePaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/images/'))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          mainAxisExtent: 110,
        ),
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          return Draggable(
            data: _imagePaths[index],
            feedback: Image.asset(
              _imagePaths[index],
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            child: Image.asset(
              _imagePaths[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}