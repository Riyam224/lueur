class ApiEndpoints {
  static const String baseUrl = 'https://web-production-f8628.up.railway.app';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String authVerify = '/api/auth/verify/';

  // ── Accounts ─────────────────────────────────────────────────────────────
  static const String accountsMe = '/api/accounts/me/';

  // ── Companion ────────────────────────────────────────────────────────────
  static const String generate = '/api/companion/generate/';
  static const String history = '/api/companion/history/';
  static const String weeklyLetter = '/api/companion/weekly-letter/';
}
