/// Where the user chose to go after a low-mood check-in — routes the
/// floating mood-choice dialog and the affirmation screen that follows it.
enum MoodChoiceDestination {
  talkToLuna,
  breathing,
  freeDraw,
  sudoku;

  static MoodChoiceDestination fromName(String? name) => values.firstWhere(
        (d) => d.name == name,
        orElse: () => MoodChoiceDestination.talkToLuna,
      );
}
