class ApiEndpoints {
  static const String baseUrl = 'https://web-production-f8628.up.railway.app';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String authVerify = '/api/auth/verify/';

  // ── Therapist ─────────────────────────────────────────────────────────────
  static const String generate = '/api/therapist/generate/';
  static const String history = '/api/therapist/history/';
  static const String weeklyLetter = '/api/therapist/weekly-letter/';
}
