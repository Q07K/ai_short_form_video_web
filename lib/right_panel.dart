import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RightPanel extends StatefulWidget {
  const RightPanel({super.key});

  @override
  _RightPanelState createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  List<TextEditingController> testWidgetControllers = [TextEditingController()];
  List<TextEditingController> secondTextControllers = [TextEditingController()];
  List<bool> _checkedItems = [];

  @override
  void initState() {
    super.initState();
    _checkedItems = List.generate(testWidgetControllers.length, (index) => false);
  }

  void addTestWidgetAt(int index) {
    setState(() {
      testWidgetControllers.insert(index + 1, TextEditingController());
      secondTextControllers.insert(index + 1, TextEditingController());
      _checkedItems.insert(index + 1, false);
    });
  }

  void addTestWidget() {
    setState(() {
      testWidgetControllers.add(TextEditingController());
      secondTextControllers.add(TextEditingController());
      _checkedItems.add(false);
    });
  }

  void deleteCheckedWidgets() {
    setState(() {
      testWidgetControllers = List.from(testWidgetControllers.asMap().entries.where((entry) => !_checkedItems[entry.key]).map((entry) => entry.value));
      secondTextControllers = List.from(secondTextControllers.asMap().entries.where((entry) => !_checkedItems[entry.key]).map((entry) => entry.value));
       _checkedItems = List.from(_checkedItems.asMap().entries.where((entry) => !_checkedItems[entry.key]).map((entry) => entry.value));
    });
  }

  void deleteThisWidget(int index) {
    setState(() {
      if (testWidgetControllers.length > 1) {
         testWidgetControllers.removeAt(index);
          secondTextControllers.removeAt(index);
          _checkedItems.removeAt(index);
      }
    });
  }

  int _hoveredButtonIndex = -1;

  void toggleCheckbox(int index, bool value) {
    setState(() {
      _checkedItems[index] = value;
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
                 onReorder: (oldIndex, newIndex) {
                    setState(() {
                      int oldWidgetIndex = oldIndex ~/ 2;
                      int newWidgetIndex = newIndex ~/ 2;

                     if(oldIndex.isEven && newIndex.isEven) {
                       if(newWidgetIndex < oldWidgetIndex) {
                            final item = testWidgetControllers.removeAt(oldWidgetIndex);
                           final secondItem = secondTextControllers.removeAt(oldWidgetIndex);
                             final checkedItem = _checkedItems.removeAt(oldWidgetIndex);
                           testWidgetControllers.insert(newWidgetIndex, item);
                            secondTextControllers.insert(newWidgetIndex, secondItem);
                              _checkedItems.insert(newWidgetIndex, checkedItem);
                            } else if (newWidgetIndex > oldWidgetIndex){
                              final item = testWidgetControllers.removeAt(oldWidgetIndex);
                                 final secondItem = secondTextControllers.removeAt(oldWidgetIndex);
                                 final checkedItem = _checkedItems.removeAt(oldWidgetIndex);
                                testWidgetControllers.insert(newWidgetIndex, item);
                                 secondTextControllers.insert(newWidgetIndex, secondItem);
                                 _checkedItems.insert(newWidgetIndex, checkedItem);
                             }
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
                      secondTextController: secondTextControllers[widgetIndex],
                      listIndex: widgetIndex,
                      onDelete: () => deleteThisWidget(widgetIndex),
                      isChecked: _checkedItems[widgetIndex],
                      onCheckboxChanged: (value) => toggleCheckbox(widgetIndex, value),
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

  const TestWidget({
    super.key,
    required this.textController,
     required this.secondTextController,
    required this.listIndex,
    required this.onDelete,
    required this.isChecked,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
       child: Container(
         padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
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
                               child:  TextField(
                                 controller: textController,
                                    decoration: const InputDecoration(                                      
                                       border: OutlineInputBorder(),
                                       isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), // 수평 패딩 추가
                                     ),
                                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                                ),
                             ),
                           ],
                         ),
                          const SizedBox(height: 5),
                           Row(
                               children: [
                                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                                  const SizedBox(width: 5),
                                   Expanded(
                                     child: TextField(
                                       controller: secondTextController,
                                        decoration: const InputDecoration(                                          
                                           border: OutlineInputBorder(),
                                           isDense: true,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),  // 수평 패딩 추가
                                        ),
                                         style: const TextStyle(color: Colors.grey, fontSize: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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