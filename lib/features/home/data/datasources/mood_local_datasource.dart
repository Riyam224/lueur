import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';

/// A long-time journaler's cache can grow into thousands of entries, so
/// decoding/encoding runs off the UI isolate via [compute] to avoid jank.
List<MoodEntryModel> _decodeEntries(String jsonStr) {
  final list = jsonDecode(jsonStr) as List<dynamic>;
  return list
      .map((e) => MoodEntryModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

String _encodeEntries(List<MoodEntryModel> entries) {
  return jsonEncode(entries.map((e) => e.toJson()).toList());
}

class MoodLocalDatasource {
  static const String boxName = 'mood_cache';
  static const String guestUserId = '';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so entries never bleed between accounts on the same device
  String _key(String userId) => 'entries_$userId';

  Future<List<MoodEntryModel>> getCachedHistory({
    required String userId,
  }) async {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    return compute(_decodeEntries, jsonStr);
  }

  Future<void> cacheHistory(
    List<MoodEntryModel> entries, {
    required String userId,
  }) async {
    final encoded = await compute(_encodeEntries, entries);
    await _box.put(_key(userId), encoded);
  }

  Future<void> addEntry(MoodEntryModel entry, {required String userId}) async {
    final existing = await getCachedHistory(userId: userId);
    final updated = [
      entry,
      ...existing.where((e) => e.id != entry.id),
    ];
    await cacheHistory(updated, userId: userId);
  }

  Future<void> deleteEntry(int id, {required String userId}) async {
    final existing = await getCachedHistory(userId: userId);
    final updated = existing.where((e) => e.id != id).toList();
    await cacheHistory(updated, userId: userId);
  }

  Future<void> deleteAllEntries({required String userId}) async {
    await _box.delete(_key(userId));
  }

  /// Guest history is intentionally session-only. Registered-user keys are
  /// never touched by this cleanup.
  Future<void> clearGuestHistory() => deleteAllEntries(userId: guestUserId);

  /// Sets the journal grid card color for a single entry. Returns the
  /// updated entry, or null if no entry with [id] is cached.
  Future<MoodEntryModel?> setCardColor(
    int id,
    String cardColor, {
    required String userId,
  }) async {
    final existing = await getCachedHistory(userId: userId);
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
    final existing = await getCachedHistory(userId: userId);
    final index = existing.indexWhere((e) => e.id == id);
    if (index == -1) return null;

    final updated = existing[index].copyWith(pinned: pinned);
    final newList = List<MoodEntryModel>.from(existing)..[index] = updated;
    await cacheHistory(newList, userId: userId);
    return updated;
  }
}
