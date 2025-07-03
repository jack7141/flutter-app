import 'package:flutter/material.dart';

import '../../../config/app_config.dart';
import '../models/celeb_models.dart';
import '../repos/celeb_repo.dart';

class CelebData extends ChangeNotifier {
  final CelebRepo _celebRepo = CelebRepo();

  List<CelebModel> _celebs = [];
  bool _isLoading = false;
  int _selectedIndex = -1;

  // Getter
  List<CelebModel> get celebs => _celebs;
  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;

  // Setter
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  // 연예인 목록 로딩
  Future<void> _loadCelebs() async {
    if (AppConfig.enableDebugLogs) {
      print("🔄 연예인 목록 로딩 시작");
    }

    _isLoading = true;
    notifyListeners();

    final celebList = await _celebRepo.getCelebs();

    if (celebList != null && celebList.isNotEmpty) {
      _celebs = celebList;
      if (AppConfig.enableDebugLogs) {
        print("✅ 연예인 목록 로딩 완료: ${_celebs.length}개");
        for (var celeb in _celebs) {
          print("📋 연예인: ${celeb.name}, 이미지: ${celeb.imagePath}");
        }
      }
    } else {
      if (AppConfig.enableDebugLogs) {
        print("❌ 연예인 목록이 비어있거나 로딩 실패");
      }
      _celebs = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // 새로고침 함수
  Future<void> refreshCelebs() async {
    await _loadCelebs();
  }

  // 초기 로딩 함수
  Future<void> loadInitialCelebs() async {
    if (_celebs.isEmpty) {
      await _loadCelebs();
    }
  }

  // 선택된 인덱스 업데이트 (토글 지원)
  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // 선택 해제
  void clearSelection() {
    _selectedIndex = -1;
    notifyListeners();
  }
}
