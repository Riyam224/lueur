class ApiEndpoints {
  static const String baseUrl = 'https://web-production-f8628.up.railway.app';
  static const String _v1 = '/api/v1';

  static const String authVerify = '$_v1/auth/verify/';

  static const String accountsMe = '$_v1/accounts/me/';

static const String generate = '$_v1/companion/generate/';
  static const String history = '$_v1/companion/history/';
  static const String weeklyLetter = '$_v1/companion/weekly-letter/';
  static const String activity = '$_v1/companion/activity/';
  static const String deleteAllEntries = '$_v1/companion/entries/delete-all/';

  static String deleteEntry(String entryId) =>
      '$_v1/companion/entries/$entryId/delete/';
}
