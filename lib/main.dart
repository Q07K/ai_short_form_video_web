import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';

import 'right_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AI Short from Video')),
        body: const VideoEditorScreen(),
      ),
    );
  }
}

class VideoEditorScreen extends StatelessWidget {
  const VideoEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[200],
            child: const LeftPanel(),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[100],
            child: const RightPanel(), // RightPanel 위젯 사용
          ),
        ),
      ],
    );
  }
}

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
              child: const Center(child: Placeholder()),
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
    return Container(
      height: 250,
      child: Scrollable(
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return GridView.builder(
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
          );
        },
      ),
    );
  }
}
