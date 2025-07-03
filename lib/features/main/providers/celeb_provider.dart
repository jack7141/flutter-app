import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/celeb_models.dart';

// 선택된 셀럽 상태 관리
final selectedCelebProvider = StateProvider<CelebModel?>((ref) => null);
