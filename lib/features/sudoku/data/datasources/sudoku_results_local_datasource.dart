import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/sudoku/data/models/sudoku_result_model.dart';

/// A long-time player's result history can grow large, so decoding/encoding
/// runs off the UI isolate via [compute] to avoid janking/ANRing the app.
List<SudokuResultModel> _decodeResults(String jsonStr) {
  final list = jsonDecode(jsonStr) as List<dynamic>;
  return list
      .map((e) => SudokuResultModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

String _encodeResults(List<SudokuResultModel> results) {
  return jsonEncode(results.map((r) => r.toJson()).toList());
}

class SudokuResultsLocalDatasource {
  static const String boxName = 'sudoku_results';
  static const String guestUserId = '';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so results never bleed between accounts on the same device
  String _key(String userId) => 'sudoku_results_$userId';

  Future<List<SudokuResultModel>> getResults({required String userId}) async {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    return compute(_decodeResults, jsonStr);
  }

  Future<void> saveResult(
    SudokuResultModel result, {
    required String userId,
  }) async {
    final existing = await getResults(userId: userId);
    final updated = [result, ...existing];
    final encoded = await compute(_encodeResults, updated);
    await _box.put(_key(userId), encoded);
  }

  Future<void> deleteResult(String id, {required String userId}) async {
    final existing = await getResults(userId: userId);
    final updated = existing.where((r) => r.id != id).toList();
    final encoded = await compute(_encodeResults, updated);
    await _box.put(_key(userId), encoded);
  }

  Future<void> clearAllForUser({required String userId}) =>
      _box.delete(_key(userId));

  /// Guest results are intentionally session-only. Registered-user keys are
  /// never touched by this cleanup.
  Future<void> clearGuestResults() => clearAllForUser(userId: guestUserId);
}
