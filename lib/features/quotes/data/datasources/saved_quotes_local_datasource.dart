import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/quotes/data/models/saved_quote_model.dart';

List<SavedQuoteModel> _decodeQuotes(String jsonStr) {
  final list = jsonDecode(jsonStr) as List<dynamic>;
  return list
      .map((e) => SavedQuoteModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

String _encodeQuotes(List<SavedQuoteModel> quotes) {
  return jsonEncode(quotes.map((q) => q.toJson()).toList());
}

class SavedQuotesLocalDatasource {
  static const String boxName = 'saved_quotes';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so quotes never bleed between accounts on the same device
  String _key(String userId) => 'quotes_$userId';

  Future<List<SavedQuoteModel>> getQuotes({required String userId}) async {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    return compute(_decodeQuotes, jsonStr);
  }

  Future<void> saveQuote(SavedQuoteModel quote, {required String userId}) async {
    final existing = await getQuotes(userId: userId);
    final updated = [
      quote,
      ...existing.where((q) => q.text != quote.text),
    ];
    final encoded = await compute(_encodeQuotes, updated);
    await _box.put(_key(userId), encoded);
  }

  Future<void> deleteQuote(String id, {required String userId}) async {
    final existing = await getQuotes(userId: userId);
    final updated = existing.where((q) => q.id != id).toList();
    final encoded = await compute(_encodeQuotes, updated);
    await _box.put(_key(userId), encoded);
  }

  Future<void> clearAllForUser({required String userId}) =>
      _box.delete(_key(userId));
}
