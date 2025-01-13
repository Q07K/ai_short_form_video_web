//main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Right_Panel.dart';
import 'Left_Panel.dart';
import 'EditorState.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditorState(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('AI Short from Video')),
          body: const EditorScreen(),
        ),
      ),
    );
  }
}

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

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
            child: const RightPanel(),
          ),
        ),
      ],
    );
  }
}