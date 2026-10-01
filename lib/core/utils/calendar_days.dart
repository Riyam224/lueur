/// Whole calendar days from [date] to [now] in local time — 23:00 yesterday
/// seen at 08:00 today is 1 ("Yesterday"), not 0 like a 24-hour count.
/// Compared as UTC dates so a DST shift can't turn a day into 23/25 hours.
int calendarDaysAgo(DateTime date, DateTime now) {
  final local = date.toLocal();
  final today = now.toLocal();
  return DateTime.utc(today.year, today.month, today.day)
      .difference(DateTime.utc(local.year, local.month, local.day))
      .inDays;
}
