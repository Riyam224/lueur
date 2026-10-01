/// A copy of [items] without its first element matching [test] — unlike
/// `where(!test)`, it never drops further matches. Used where several
/// entries can share one id (local placeholders all use id 0).
List<T> withoutFirstWhere<T>(List<T> items, bool Function(T item) test) {
  final index = items.indexWhere(test);
  if (index < 0) return List<T>.of(items);
  return [...items.sublist(0, index), ...items.sublist(index + 1)];
}
