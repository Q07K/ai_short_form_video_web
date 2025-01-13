//Left_Panel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'Editable_Image.dart';
import 'EditorState.dart';

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Consumer<EditorState>(
                  builder: (context, editorState, child) {
                    
                    List<Widget> customBoards = editorState.customBoardKeys.entries
                        .map((entry) => CustomBoard(key: entry.value))
                        .toList();

                
                    List<Widget> allWidgets = [
                      const Center(child: Text("Select a Test Widget")),
                      ...customBoards,
                    ];

                    
                    return IndexedStack(
                      index: editorState.indexedStackIndex,
                      children: allWidgets,
                    );
                  },
                ),
              ),
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
  final Map<String, Size> _imageSizes = {};

  @override
  void initState() {
    super.initState();
    _loadAssetImages();
  }

  Future<void> _loadAssetImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final imagePaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/images/'))
        .toList();

    for (final path in imagePaths) {
      final image = Image.asset(path);
      final Completer<ui.Image> completer = Completer<ui.Image>();
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
          (ImageInfo info, bool _) {
            completer.complete(info.image);
          },
        ),
      );
      final uiImage = await completer.future;
      _imageSizes[path] =
          Size(uiImage.width.toDouble(), uiImage.height.toDouble());
    }

    setState(() {
      _imagePaths = imagePaths;
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
          final imagePath = _imagePaths[index];
          final originalSize =
              _imageSizes[imagePath] ?? const Size(1, 1); // Provide a default size
          final feedbackHeight =
              100 * (originalSize.height / originalSize.width);

          return Draggable(
            data: imagePath,
            feedback: Image.asset(
              imagePath,
              width: 100,
              height: feedbackHeight,
              fit: BoxFit.contain,
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}