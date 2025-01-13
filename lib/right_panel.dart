// Right_Panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'EditorState.dart';

class RightPanel extends StatefulWidget {
  const RightPanel({super.key});

  @override
  _RightPanelState createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  List<TextEditingController> testWidgetControllers = [TextEditingController()];
  List<TextEditingController> secondTextControllers = [TextEditingController()];
  List<bool> _checkedItems = [];
  int? _selectedWidgetIndex; // 현재 선택된 위젯의 인덱스 (null이면 선택 안됨)
  List<String> testWidgetUniqueKeys = [const Uuid().v4()];

  @override
  void initState() {
    super.initState();
    _checkedItems =
        List.generate(testWidgetControllers.length, (index) => false);
    // 초기 1번 TestWidget의 고유 키를 EditorState에 전달
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditorState>(context, listen: false)
          .addTestWidget(testWidgetUniqueKeys[0]);
    });
  }

  // EditorState의 addTestWidget 호출
  void addTestWidgetAt(int index) {
    setState(() {
      String uniqueKey = const Uuid().v4(); // 고유 키 생성
      testWidgetControllers.insert(index + 1, TextEditingController());
      secondTextControllers.insert(index + 1, TextEditingController());
      _checkedItems.insert(index + 1, false);
      testWidgetUniqueKeys.insert(index + 1, uniqueKey);
      _selectedWidgetIndex = null;
      Provider.of<EditorState>(context, listen: false)
          .addTestWidget(uniqueKey); // 고유 키 전달
      Provider.of<EditorState>(context, listen: false).selectTestWidget(null);
    });
  }

  //  EditorState의 addTestWidget 호출
  void addTestWidget() {
    setState(() {
      String uniqueKey = const Uuid().v4(); // 고유 키 생성
      testWidgetControllers.add(TextEditingController());
      secondTextControllers.add(TextEditingController());
      _checkedItems.add(false);
      testWidgetUniqueKeys.add(uniqueKey);
      _selectedWidgetIndex = null;
      Provider.of<EditorState>(context, listen: false)
          .addTestWidget(uniqueKey); // 고유 키 전달
      Provider.of<EditorState>(context, listen: false).selectTestWidget(null);
    });
  }

  void deleteCheckedWidgets() {
    setState(() {
      List<int> indicesToRemove = [];
      for (int i = 0; i < _checkedItems.length; i++) {
        if (_checkedItems[i]) {
          indicesToRemove.add(i);
        }
      }

      // 인덱스가 큰 것부터 삭제
      for (int i = indicesToRemove.length - 1; i >= 0; i--) {
        int indexToRemove = indicesToRemove[i];

        if (indexToRemove < testWidgetControllers.length) {
          testWidgetControllers.removeAt(indexToRemove);
        }
        if (indexToRemove < secondTextControllers.length) {
          secondTextControllers.removeAt(indexToRemove);
        }
        if (indexToRemove < _checkedItems.length) {
          _checkedItems.removeAt(indexToRemove);
        }
        if (indexToRemove < testWidgetUniqueKeys.length) {
          String uniqueKeyToRemove = testWidgetUniqueKeys[indexToRemove];
          Provider.of<EditorState>(context, listen: false)
              .deleteTestWidget(uniqueKeyToRemove);
          testWidgetUniqueKeys.removeAt(indexToRemove);
        }
      }

      if (_selectedWidgetIndex != null && indicesToRemove.isNotEmpty) {
        // 선택된 위젯보다 앞에 있는 삭제된 위젯의 수 계산
        int deletedBeforeSelected = indicesToRemove
            .where((index) => index < _selectedWidgetIndex!)
            .length;
        _selectedWidgetIndex = _selectedWidgetIndex! - deletedBeforeSelected;
      }

      if (_selectedWidgetIndex != null &&
          _selectedWidgetIndex! >= testWidgetControllers.length) {
        _selectedWidgetIndex = null;
      }

      Provider.of<EditorState>(context, listen: false).selectTestWidget(
          _selectedWidgetIndex != null
              ? testWidgetUniqueKeys[_selectedWidgetIndex!]
              : null);
    });
  }

  void deleteThisWidget(int index) {
    setState(() {
      if (testWidgetControllers.length > 1) {
        String uniqueKeyToRemove = testWidgetUniqueKeys[index];

        testWidgetControllers.removeAt(index);
        secondTextControllers.removeAt(index);
        _checkedItems.removeAt(index);
        testWidgetUniqueKeys.removeAt(index);

        Provider.of<EditorState>(context, listen: false)
            .deleteTestWidget(uniqueKeyToRemove);

        if (_selectedWidgetIndex == index) {
          _selectedWidgetIndex = null;
          Provider.of<EditorState>(context, listen: false)
              .selectTestWidget(null);
        } else if (_selectedWidgetIndex != null &&
            index < _selectedWidgetIndex!) {
          _selectedWidgetIndex = _selectedWidgetIndex! - 1;
          Provider.of<EditorState>(context, listen: false).selectTestWidget(
              _selectedWidgetIndex != null
                  ? testWidgetUniqueKeys[_selectedWidgetIndex!]
                  : null);
        }
      }
    });
  }

  int _hoveredButtonIndex = -1;

  void toggleCheckbox(int index, bool value) {
    setState(() {
      _checkedItems[index] = value;
      if (!value) {
        if (_selectedWidgetIndex == index) {
          _selectedWidgetIndex = null;
          //  EditorState의 selectTestWidget 호출
          Provider.of<EditorState>(context, listen: false)
              .selectTestWidget(null);
        }
      }
    });
  }

  //  EditorState의 selectTestWidget 호출
  void selectWidget(int index) {
    setState(() {
      String? uniqueKey = testWidgetUniqueKeys[index];
      if (_selectedWidgetIndex == index) {
        _selectedWidgetIndex = null;
        uniqueKey = null;
      } else {
        _selectedWidgetIndex = index;
      }
      Provider.of<EditorState>(context, listen: false)
          .selectTestWidget(uniqueKey); // 고유 키 전달
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("widgets menu bar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: deleteCheckedWidgets,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                //  위젯 재정렬 후 EditorState의 selectTestWidget 호출
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    int oldWidgetIndex = oldIndex ~/ 2;
                    int newWidgetIndex;

                    // newIndex 조정: 버튼 위젯 사이로 드래그된 경우를 고려
                    if (newIndex.isOdd) {
                      newWidgetIndex = (newIndex + 1) ~/ 2;
                    } else {
                      newWidgetIndex = newIndex ~/ 2;
                    }

                    // newIndex가 oldIndex보다 작을 때와 클 때를 분리하여 처리
                    if (newWidgetIndex < oldWidgetIndex) {
                      final item =
                          testWidgetControllers.removeAt(oldWidgetIndex);
                      final secondItem =
                          secondTextControllers.removeAt(oldWidgetIndex);
                      final checkedItem = _checkedItems.removeAt(oldWidgetIndex);
                      final uniqueKeyItem =
                          testWidgetUniqueKeys.removeAt(oldWidgetIndex);
                      testWidgetControllers.insert(newWidgetIndex, item);
                      secondTextControllers.insert(newWidgetIndex, secondItem);
                      _checkedItems.insert(newWidgetIndex, checkedItem);
                      testWidgetUniqueKeys.insert(newWidgetIndex, uniqueKeyItem);
                      if (_selectedWidgetIndex != null) {
                        if (_selectedWidgetIndex == oldWidgetIndex) {
                          _selectedWidgetIndex = newWidgetIndex;
                        } else if (_selectedWidgetIndex! > oldWidgetIndex &&
                            _selectedWidgetIndex! <= newWidgetIndex) {
                          _selectedWidgetIndex = _selectedWidgetIndex! - 1;
                        } else if (_selectedWidgetIndex! < oldWidgetIndex &&
                            _selectedWidgetIndex! >= newWidgetIndex) {
                          _selectedWidgetIndex = _selectedWidgetIndex! + 1;
                        }
                      }
                    } else if (newWidgetIndex > oldWidgetIndex) {
                      final item =
                          testWidgetControllers.removeAt(oldWidgetIndex);
                      final secondItem =
                          secondTextControllers.removeAt(oldWidgetIndex);
                      final checkedItem = _checkedItems.removeAt(oldWidgetIndex);
                      final uniqueKeyItem =
                          testWidgetUniqueKeys.removeAt(oldWidgetIndex);
                      testWidgetControllers.insert(newWidgetIndex - 1, item);
                      secondTextControllers.insert(newWidgetIndex - 1, secondItem);
                      _checkedItems.insert(newWidgetIndex - 1, checkedItem);
                      testWidgetUniqueKeys.insert(
                          newWidgetIndex - 1, uniqueKeyItem);
                      if (_selectedWidgetIndex != null) {
                        if (_selectedWidgetIndex == oldWidgetIndex) {
                          _selectedWidgetIndex = newWidgetIndex - 1;
                        } else if (_selectedWidgetIndex! < oldWidgetIndex ||
                            _selectedWidgetIndex! >= newWidgetIndex) {
                          // 변경 없음 (이동 범위 밖)
                        } else if (_selectedWidgetIndex! > oldWidgetIndex &&
                            _selectedWidgetIndex! < newWidgetIndex) {
                          _selectedWidgetIndex = _selectedWidgetIndex! - 1;
                        }
                      }
                    }

                    // EditorState 업데이트
                    if (_selectedWidgetIndex != null) {
                      Provider.of<EditorState>(context, listen: false)
                          .selectTestWidget(
                              testWidgetUniqueKeys[_selectedWidgetIndex!]);
                    } else {
                      Provider.of<EditorState>(context, listen: false)
                          .selectTestWidget(null);
                    }
                  });
                },
                itemCount: testWidgetControllers.length * 2,
                itemBuilder: (context, index) {
                  if (index.isEven) {
                    final widgetIndex = index ~/ 2;
                    return InkWell(
                      key: ValueKey(
                          'TestWidget-${testWidgetUniqueKeys[widgetIndex]}'),
                      onTap: () => selectWidget(widgetIndex),
                      child: TestWidget(
                        textController: testWidgetControllers[widgetIndex],
                        secondTextController:
                            secondTextControllers[widgetIndex],
                        listIndex: widgetIndex,
                        onDelete: () => deleteThisWidget(widgetIndex),
                        isChecked: _checkedItems[widgetIndex],
                        onCheckboxChanged: (value) =>
                            toggleCheckbox(widgetIndex, value),
                        isSelected: _selectedWidgetIndex == widgetIndex,
                        onSecondTextChanged: (text) {
                          final editorState =
                              Provider.of<EditorState>(context, listen: false);
                          editorState.updateCustomBoardText(
                              testWidgetUniqueKeys[widgetIndex], text);
                        },
                      ),
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
      ),
    );
  }
}

class TestWidget extends StatelessWidget {
  final TextEditingController textController;
  final TextEditingController secondTextController;
  final int listIndex;
  final VoidCallback onDelete;
  final bool isChecked;
  final void Function(bool) onCheckboxChanged;
  final bool isSelected;
  final void Function(String)? onSecondTextChanged;

  const TestWidget({
    super.key,
    required this.textController,
    required this.secondTextController,
    required this.listIndex,
    required this.onDelete,
    required this.isChecked,
    required this.onCheckboxChanged,
    required this.isSelected,
    this.onSecondTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ReorderableDragStartListener(
                        index: listIndex * 2,
                        child: const Icon(Icons.list, size: 24),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${listIndex + 1}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        if (value != null) {
                          onCheckboxChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                            ),
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: secondTextController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                            ),
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 16),
                            onChanged: onSecondTextChanged,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: Opacity(
          opacity: hoveredButtonIndex == buttonIndex ? 1.0 : 0.5,
          child: ElevatedButton(
            onPressed: () => addTestWidgetAt(buttonIndex),
            child: Text('Add below widget ${buttonIndex + 1}'),
          ),
        ),
      ),
    );
  }
}