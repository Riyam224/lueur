int _lastLocalEntryId = 0;

/// A unique temporary id for an entry that only exists on this device
/// (placeholders, guest activities, fallback replies).
///
/// Always negative, so it can never collide with a server id (positive).
/// Time-based, so ids stay distinct across app restarts, and forced to
/// strictly decrease within a process so two calls in the same microsecond
/// still differ.
int nextLocalEntryId() {
  final candidate = -DateTime.now().microsecondsSinceEpoch;
  _lastLocalEntryId =
      (_lastLocalEntryId != 0 && candidate >= _lastLocalEntryId)
          ? _lastLocalEntryId - 1
          : candidate;
  return _lastLocalEntryId;
}
