import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';

class MoodLocalDatasource {
  static const String boxName = 'mood_cache';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so entries never bleed between accounts on the same device
  String _key(String userId) => 'entries_$userId';

  /// Get cached mood entries for [userId]
  List<MoodEntryModel> getCachedHistory({required String userId}) {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => MoodEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cache the entire list of entries for [userId]
  Future<void> cacheHistory(
      List<MoodEntryModel> entries, {required String userId,}) async {
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }

  /// Add a new entry for [userId], avoiding duplicates by id
  Future<void> addEntry(MoodEntryModel entry, {required String userId}) async {
    final existing = getCachedHistory(userId: userId);
    final updated = [
      entry,
      ...existing.where((e) => e.id != entry.id),
    ];
    await cacheHistory(updated, userId: userId);
  }

  /// Delete an entry by id for [userId]
  Future<void> deleteEntry(int id, {required String userId}) async {
    final existing = getCachedHistory(userId: userId);
    final updated = existing.where((e) => e.id != id).toList();
    await cacheHistory(updated, userId: userId);
  }

  /// Clears all cached entries for [userId]
  Future<void> deleteAllEntries({required String userId}) async {
    await _box.delete(_key(userId));
  }

  /// Sets the journal grid card color for a single entry. Returns the
  /// updated entry, or null if no entry with [id] is cached.
  Future<MoodEntryModel?> setCardColor(
    int id,
    String cardColor, {
    required String userId,
  }) async {
    final existing = getCachedHistory(userId: userId);
    final index = existing.indexWhere((e) => e.id == id);
    if (index == -1) return null;

    final updated = existing[index].copyWith(cardColor: cardColor);
    final newList = List<MoodEntryModel>.from(existing)..[index] = updated;
    await cacheHistory(newList, userId: userId);
    return updated;
  }

  /// Sets the journal grid pinned flag for a single entry. Returns the
  /// updated entry, or null if no entry with [id] is cached.
  Future<MoodEntryModel?> setPinned(
    int id,
    bool pinned, {
    required String userId,
  }) async {
    final existing = getCachedHistory(userId: userId);
    final index = existing.indexWhere((e) => e.id == id);
    if (index == -1) return null;

    final updated = existing[index].copyWith(pinned: pinned);
    final newList = List<MoodEntryModel>.from(existing)..[index] = updated;
    await cacheHistory(newList, userId: userId);
    return updated;
  }
}
