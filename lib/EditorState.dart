// EditorState.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'Editable_Image.dart';

class EditorState with ChangeNotifier {
  String? _selectedTestWidgetKey; // 선택된 TestWidget의 고유 키
  final Map<String, GlobalKey<CustomBoardState>> _customBoardKeys = {};
  final Map<String, String> _customBoardTexts = {}; // TestWidget별 텍스트 저장

  String? get selectedTestWidgetKey => _selectedTestWidgetKey;
  Map<String, GlobalKey<CustomBoardState>> get customBoardKeys =>
      _customBoardKeys;

  int get indexedStackIndex {
    if (_selectedTestWidgetKey == null) {
      return 0;
    } else {
      // _customBoardKeys의 키 리스트에서 _selectedTestWidgetKey의 인덱스를 찾아서 반환
      int index =
          _customBoardKeys.keys.toList().indexOf(_selectedTestWidgetKey!);
      if (index == -1) {
        return 0;
      } else {
        return index + 1; // 수정된 부분
      }
    }
  }

  // TestWidget 추가 시 호출되는 함수 (고유 키 사용)
  void addTestWidget(String uniqueKey) {
    if (!_customBoardKeys.containsKey(uniqueKey)) {
      _customBoardKeys[uniqueKey] = GlobalKey<CustomBoardState>();
      _customBoardTexts[uniqueKey] = ''; // 텍스트 초기화
      notifyListeners();
    }
  }

  void selectTestWidget(String? uniqueKey) {
    _selectedTestWidgetKey = uniqueKey;
    notifyListeners();
  }

  void deleteTestWidget(String uniqueKey) {
    if (_customBoardKeys.containsKey(uniqueKey)) {
      _customBoardKeys.remove(uniqueKey);
      _customBoardTexts.remove(uniqueKey); // 텍스트 삭제
      notifyListeners();
    }
  }

  // 텍스트 업데이트 함수
  void updateCustomBoardText(String uniqueKey, String text) {
    _customBoardTexts[uniqueKey] = text;
    if (_customBoardKeys.containsKey(uniqueKey)) {
      _customBoardKeys[uniqueKey]
          ?.currentState
          ?.updateText(text); // CustomBoardState의 updateText 호출
    }
    notifyListeners();
  }

  // 현재 선택된 TestWidget의 텍스트 반환
  String? get selectedCustomBoardText {
    if (_selectedTestWidgetKey != null) {
      return _customBoardTexts[_selectedTestWidgetKey!];
    } else {
      return null;
    }
  }
}