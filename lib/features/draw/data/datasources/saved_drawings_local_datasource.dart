import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/draw/data/models/saved_drawing_model.dart';

class SavedDrawingsLocalDatasource {
  static const String boxName = 'saved_drawings';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so drawings never bleed between accounts on the same device
  String _key(String userId) => 'drawings_$userId';

  List<SavedDrawingModel> getDrawings({required String userId}) {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => SavedDrawingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDrawing(
    SavedDrawingModel drawing, {
    required String userId,
  }) async {
    final existing = getDrawings(userId: userId);
    final updated = [drawing, ...existing];
    final encoded = jsonEncode(updated.map((d) => d.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }

  Future<void> deleteDrawing(String id, {required String userId}) async {
    final existing = getDrawings(userId: userId);
    final updated = existing.where((d) => d.id != id).toList();
    final encoded = jsonEncode(updated.map((d) => d.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }
}
