import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/draw/data/models/saved_drawing_model.dart';

/// Freehand strokes can carry thousands of points, so decoding/encoding
/// runs off the UI isolate via [compute] to avoid janking/ANRing the app.
List<SavedDrawingModel> _decodeDrawings(String jsonStr) {
  final list = jsonDecode(jsonStr) as List<dynamic>;
  return list
      .map((e) => SavedDrawingModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

String _encodeDrawings(List<SavedDrawingModel> drawings) {
  return jsonEncode(drawings.map((d) => d.toJson()).toList());
}

class SavedDrawingsLocalDatasource {
  static const String boxName = 'saved_drawings';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so drawings never bleed between accounts on the same device
  String _key(String userId) => 'drawings_$userId';

  Future<List<SavedDrawingModel>> getDrawings({required String userId}) async {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    return compute(_decodeDrawings, jsonStr);
  }

  Future<void> saveDrawing(
    SavedDrawingModel drawing, {
    required String userId,
  }) async {
    final existing = await getDrawings(userId: userId);
    final updated = [drawing, ...existing];
    final encoded = await compute(_encodeDrawings, updated);
    await _box.put(_key(userId), encoded);
  }

  Future<void> deleteDrawing(String id, {required String userId}) async {
    final existing = await getDrawings(userId: userId);
    final updated = existing.where((d) => d.id != id).toList();
    final encoded = await compute(_encodeDrawings, updated);
    await _box.put(_key(userId), encoded);
  }
}
