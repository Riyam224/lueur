import 'package:sentry_flutter/sentry_flutter.dart';

/// Sensitive-data substrings that must never leave the device via Sentry.
/// Mirrors the redaction rules enforced server-side by the Django backend's
/// `_sentry_before_send` (core/settings.py) — journal entries and Luna
/// chat/mood content stay local no matter which side produced the event.
const List<String> _sensitiveKeySubstrings = [
  'journal',
  'mood',
  'message',
  'luna',
  'chat',
  'entry',
];

const String _redacted = '[Filtered]';

bool _isSensitive(String text) {
  final lower = text.toLowerCase();
  return _sensitiveKeySubstrings.any(lower.contains);
}

/// Recursively redacts any Map entry whose key matches a sensitive
/// substring. Non-Map/List leaves are returned unchanged.
dynamic _scrub(dynamic value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key: _isSensitive(entry.key.toString())
            ? _redacted
            : _scrub(entry.value),
    };
  }
  if (value is List) {
    return value.map(_scrub).toList();
  }
  return value;
}

Map<String, dynamic>? _scrubMap(Map<String, dynamic>? map) =>
    map == null ? null : Map<String, dynamic>.from(_scrub(map) as Map);

Breadcrumb _scrubBreadcrumb(Breadcrumb breadcrumb) {
  final message = breadcrumb.message;
  final category = breadcrumb.category;
  final textIsSensitive = (message != null && _isSensitive(message)) ||
      (category != null && _isSensitive(category));

  return breadcrumb.copyWith(
    message: textIsSensitive ? _redacted : message,
    data: _scrubMap(breadcrumb.data),
  );
}

SentryRequest _scrubRequest(SentryRequest request) {
  final rawData = request.data;
  final scrubbedData = rawData is Map || rawData is List
      ? _scrub(rawData)
      : (rawData is String && _isSensitive(rawData) ? _redacted : rawData);
  final queryString = request.queryString;

  return request.copyWith(
    data: scrubbedData,
    queryString: queryString != null && _isSensitive(queryString)
        ? _redacted
        : queryString,
  );
}

/// [SentryFlutterOptions.beforeSend] hook — scrubs breadcrumbs, event
/// `extra`, and request/response data for keys or text containing journal,
/// mood, message, luna, chat, or entry (case-insensitive) before the event
/// ever leaves the device.
SentryEvent scrubSensitiveSentryData(SentryEvent event, Hint hint) {
  return event.copyWith(
    extra: _scrubMap(event.extra),
    breadcrumbs: event.breadcrumbs?.map(_scrubBreadcrumb).toList(),
    request: event.request == null ? null : _scrubRequest(event.request!),
  );
}
