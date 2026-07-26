import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/sudoku/data/models/sudoku_result_model.dart';

class SudokuResultsLocalDatasource {
  static const String boxName = 'sudoku_results';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so results never bleed between accounts on the same device
  String _key(String userId) => 'sudoku_results_$userId';

  List<SudokuResultModel> getResults({required String userId}) {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => SudokuResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveResult(
    SudokuResultModel result, {
    required String userId,
  }) async {
    final existing = getResults(userId: userId);
    final updated = [result, ...existing];
    final encoded = jsonEncode(updated.map((r) => r.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }

  Future<void> deleteResult(String id, {required String userId}) async {
    final existing = getResults(userId: userId);
    final updated = existing.where((r) => r.id != id).toList();
    final encoded = jsonEncode(updated.map((r) => r.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }
}
