import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test Widgets')),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const TestWidgetList(),
          ),
        ),
      ),
    );
  }
}

class TestWidgetList extends StatefulWidget {
  const TestWidgetList({super.key});

  @override
  _TestWidgetListState createState() => _TestWidgetListState();
}

class _TestWidgetListState extends State<TestWidgetList> {
  List<TextEditingController> testWidgetControllers = [TextEditingController()];

  void addTestWidgetAt(int index) {
    //위젯들 밑의 버튼들
    setState(() {
      testWidgetControllers.insert(index + 1, TextEditingController());
    });
  }

  void addTestWidget() {
    // 맨 밑에 버튼 담당
    setState(() {
      testWidgetControllers.add(TextEditingController());
    });
  }

  void deleteThisWidget(int index) {
    //쓰레기통 아이콘
    setState(() {
      if (testWidgetControllers.length > 1) {
        testWidgetControllers.removeAt(index);
      }
    });
  }

  /// 현재 마우스 위치 인덱스 (기본값 -1)
  int _hoveredButtonIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles:
                  false, //이거 true로 설정하면, 드래그 가능 리스트들 목록들 각각 오른쪽 화면에 웹에서만 보이는 전용 드래그 나옵니다.
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex.isOdd) {
                    // 버튼 사이로 드래그된 경우의 처리

                    newIndex = (newIndex + 1) ~/ 2;
                  } else {
                    newIndex ~/= 2;
                  }
                  oldIndex ~/= 2;

                  if (newIndex < oldIndex) {
                    // 위젯이 자신의 다음 위젯보다 위로 이동했을 때만 순서 변경
                    final item = testWidgetControllers.removeAt(oldIndex);
                    testWidgetControllers.insert(newIndex, item);
                  } else if (newIndex > oldIndex + 1) {
                    final item = testWidgetControllers.removeAt(oldIndex);
                    testWidgetControllers.insert(newIndex - 1, item);
                  }
                });
              },
              itemCount: testWidgetControllers.length * 2,
              itemBuilder: (context, index) {
                if (index.isEven) {
                  final widgetIndex = index ~/ 2;
                  return TestWidget(
                    key: ValueKey('TestWidget-$widgetIndex'),
                    textController: testWidgetControllers[widgetIndex],
                    listIndex: widgetIndex,
                    onDelete: () => deleteThisWidget(widgetIndex),
                  );
                } else {
                  final buttonIndex = index ~/ 2;
                  return AddBelowWidgetButton(
                    key: ValueKey('Button-$buttonIndex'),
                    buttonIndex: buttonIndex,
                    addTestWidgetAt: addTestWidgetAt,
                    hoveredButtonIndex: _hoveredButtonIndex,
                    onHover: (hovering) {
                      setState(() {
                        _hoveredButtonIndex = hovering ? buttonIndex : -1;
                      });
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTestWidget,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestWidget extends StatelessWidget {
  final TextEditingController textController; //위젯 순서 변경 시, 내용물 보존
  final int listIndex; //위젯들의 번호 1번, 2번 .....
  final VoidCallback onDelete;

  const TestWidget({
    super.key,
    required this.textController,
    required this.listIndex,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ReorderableDragStartListener(
                      index: listIndex *
                          2, //index를 곱해서 번호대로 index가 1이면 1번 testwidget, 2번이면 1번 testwidget 바로 밑의 버튼
                      child: const Icon(Icons.list, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${listIndex + 1}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: onDelete,
                ),
              ],
            ),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBelowWidgetButton extends StatelessWidget {
  final int buttonIndex;
  final void Function(int) addTestWidgetAt;
  final int hoveredButtonIndex;
  final void Function(bool) onHover;

  const AddBelowWidgetButton({
    super.key,
    required this.buttonIndex,
    required this.addTestWidgetAt,
    required this.hoveredButtonIndex,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: Opacity(
          opacity: hoveredButtonIndex == buttonIndex
              ? 1.0
              : 0.5, // 오른쪽 숫자를 0.0으로 하면 화면상에 보이지 않음, 순서 변경 제대로 되나 확인 위해 반투명으로 설정함
          child: ElevatedButton(
            onPressed: () => addTestWidgetAt(buttonIndex),
            child: Text('Add below widget ${buttonIndex + 1}'),
          ),
        ),
      ),
    );
  }
}
