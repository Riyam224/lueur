/// Formats a duration in seconds as `m:ss` — minutes unpadded, seconds
/// zero-padded to 2 digits.
String formatMmSs(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
