import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur_app/features/quotes/data/models/saved_quote_model.dart';

class SavedQuotesLocalDatasource {
  static const String boxName = 'saved_quotes';

  Box<String> get _box => Hive.box<String>(boxName);

  /// Per-user Hive key so quotes never bleed between accounts on the same device
  String _key(String userId) => 'quotes_$userId';

  List<SavedQuoteModel> getQuotes({required String userId}) {
    final jsonStr = _box.get(_key(userId));
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => SavedQuoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveQuote(SavedQuoteModel quote, {required String userId}) async {
    final existing = getQuotes(userId: userId);
    final updated = [
      quote,
      ...existing.where((q) => q.text != quote.text),
    ];
    final encoded = jsonEncode(updated.map((q) => q.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }

  Future<void> deleteQuote(String id, {required String userId}) async {
    final existing = getQuotes(userId: userId);
    final updated = existing.where((q) => q.id != id).toList();
    final encoded = jsonEncode(updated.map((q) => q.toJson()).toList());
    await _box.put(_key(userId), encoded);
  }
}
