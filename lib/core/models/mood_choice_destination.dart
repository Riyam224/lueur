/// Where the user chose to go after a low-mood check-in — used to route
/// the floating mood-choice dialog and the affirmation screen that follows
/// it to the right next screen.
enum MoodChoiceDestination {
  talkToLuna,
  freeDraw;

  static MoodChoiceDestination fromName(String? name) => values.firstWhere(
        (d) => d.name == name,
        orElse: () => MoodChoiceDestination.talkToLuna,
      );
}
