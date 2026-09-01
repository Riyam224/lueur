class ApiEndpoints {
  static const String baseUrl = 'https://web-production-f8628.up.railway.app';

  static const String authVerify = '/api/auth/verify/';

  static const String accountsMe = '/api/accounts/me/';

  static const String generate = '/api/companion/generate/';
  static const String history = '/api/companion/history/';
  static const String weeklyLetter = '/api/companion/weekly-letter/';
  static const String activity = '/api/companion/activity/';
  static const String deleteAllEntries = '/api/companion/entries/delete-all/';

  static String deleteEntry(String entryId) =>
      '/api/companion/entries/$entryId/delete/';
}
