// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lueur';

  @override
  String get responseScreenTitle => 'Luna\'s Response';

  @override
  String streakDaysWithLuna(int days) {
    return '$days days with Luna 🌸';
  }

  @override
  String homeGreetingMessage(String name, int streak) {
    return 'Good evening, $name 🌙 $streak days strong — I\'m proud of you.';
  }

  @override
  String homeGreetingNoEntries(String name) {
    return 'Hey $name, I\'m Luna. I\'m here whenever you\'re ready to talk 🌱';
  }

  @override
  String homeGreetingMorningStreak(String name, int streak) {
    return 'Good morning, $name! $streak-day streak — that\'s beautiful 🌸';
  }

  @override
  String homeGreetingMorning(String name) {
    return 'Good morning, $name ☀️ What\'s on your heart today?';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Hey $name 🌤️ How\'s your day going so far?';
  }

  @override
  String homeGreetingEveningNoStreak(String name) {
    return 'Good evening, $name 🌙 I\'m here if you want to talk.';
  }

  @override
  String homeGreetingLateNight(String name) {
    return 'Hey $name ⭐ Still up? I\'m listening.';
  }

  @override
  String get appTagline => 'a little light for you';

  @override
  String get onboardingSkip => 'Skip intro';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingTitle1 => 'A gentle space,\njust for you';

  @override
  String get onboardingSubtitle1 =>
      'Check in with how you\'re feeling —\nno pressure, just presence.';

  @override
  String get onboardingTitle2 => 'Meet Luna,\nyour companion';

  @override
  String get onboardingSubtitle2 =>
      'She\'s here to listen whenever\nyou need to talk it out.';

  @override
  String get onboardingTitle3 => 'Small steps,\nreal growth';

  @override
  String get onboardingSubtitle3 =>
      'Show up for yourself each day and\nwatch something beautiful grow.';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Luna missed you';

  @override
  String get loginCta => 'Talk to Luna';

  @override
  String get loginSignUpPrompt => 'Don\'t have an account? ';

  @override
  String get loginSignUpAction => 'Start growing';

  @override
  String get registerTitle => 'Start your journey';

  @override
  String get registerSubtitle => 'Luna is ready to listen';

  @override
  String get registerCta => 'Begin growing';

  @override
  String get registerSignInPrompt => 'Already have an account? ';

  @override
  String get registerSignInAction => 'Sign in';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get guestWarningTitle => 'A quick heads-up';

  @override
  String get guestWarningMessage =>
      'As a guest, Luna won\'t remember your entries once you close the app. Want to keep your streak growing? You can register anytime.';

  @override
  String get guestWarningRegisterInstead => 'Register instead';

  @override
  String get authLogOut => 'Log out';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'your@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authFullNameLabel => 'Full name';

  @override
  String get authFullNameHint => 'Your name';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authOrDivider => 'or';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and Luna will send you a link to get back in.';

  @override
  String get forgotPasswordCta => 'Send reset link';

  @override
  String get forgotPasswordEmailRequired => 'Please enter your email';

  @override
  String get forgotPasswordSuccessTitle => 'Check your email';

  @override
  String get forgotPasswordSuccessSubtitle =>
      'We sent a password reset link to your email. Follow it to set a new password.';

  @override
  String get forgotPasswordBackToLogin => 'Back to login';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authSignUpWithGoogle => 'Sign up with Google';

  @override
  String get passwordStrengthTooShort => 'Too short';

  @override
  String get passwordStrengthGettingThere => 'Getting there';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get authEmailInvalid => 'Enter a valid email address';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authConfirmPasswordMismatch => 'Passwords don\'t match';

  @override
  String get authFieldRequired => 'This field is required';

  @override
  String get homeMoodGalleryTitle => 'EXPLORE MOODS';

  @override
  String get moodLabelHappy => 'Happy';

  @override
  String get moodLabelSad => 'Sad';

  @override
  String get moodLabelAngry => 'Angry';

  @override
  String get moodLabelAnxious => 'Anxious';

  @override
  String get moodLabelCalm => 'Calm';

  @override
  String get moodLabelExcited => 'Excited';

  @override
  String get moodLabelGrateful => 'Grateful';

  @override
  String get moodLabelHopeful => 'Hopeful';

  @override
  String get moodLabelLonely => 'Lonely';

  @override
  String get moodLabelNeutral => 'Neutral';

  @override
  String get moodLabelScared => 'Scared';

  @override
  String get moodLabelBurnout => 'Burnt out';

  @override
  String get moodLabelContentPeaceful => 'Content & Peaceful';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonTalkToLuna => 'Talk to Luna';

  @override
  String get commonThisWeekLabel => 'This week';

  @override
  String get commonSavedToQuotesSnack => 'Saved to quotes 🌿';

  @override
  String get commonDismissBarrierLabel => 'Dismiss';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get lunaName => 'Luna';

  @override
  String get navHomeLabel => 'Home';

  @override
  String get navJournalLabel => 'Journal';

  @override
  String get navProfileLabel => 'Profile';

  @override
  String get moodEntryDeleteAllTitle => 'Delete all entries?';

  @override
  String get moodEntryDeleteAllMessage =>
      'This will permanently remove all journal entries from your device.';

  @override
  String get moodEntryDeleteAllConfirm => 'Delete all';

  @override
  String get moodEntryEmptyStateTitle => 'Your story starts here';

  @override
  String get moodEntryListEmptyMessage => 'No mood entries yet';

  @override
  String get homeMoodPromptLabel => 'How are you feeling today?';

  @override
  String get homeThoughtsLabelSad => 'What\'s weighing on you?';

  @override
  String get homeThoughtsLabelLonely => 'What\'s been on your mind?';

  @override
  String get homeThoughtsLabelAngry => 'What set this off?';

  @override
  String get homeThoughtsLabelWorried => 'What\'s worrying you?';

  @override
  String get homeThoughtsLabelBurnout => 'What\'s been draining you?';

  @override
  String get homeThoughtsLabelNeutralGood => 'What\'s going on today?';

  @override
  String get homeThoughtsLabelFeelGood => 'What\'s making you feel good?';

  @override
  String get homeThoughtsLabelGrateful => 'What are you grateful for?';

  @override
  String get homeThoughtsLabelHopeful => 'What are you looking forward to?';

  @override
  String get homeThoughtsLabelDefault => 'Tell me what\'s going on...';

  @override
  String get homeMoodRequiredSnack => 'Please select your mood first';

  @override
  String get homeThoughtsRequiredSnack => 'Please share your thoughts';

  @override
  String get homeThoughtsRequiredSnackFirst =>
      'Please share your thoughts first';

  @override
  String get homeShareThoughtsSectionLabel => 'SHARE YOUR THOUGHTS';

  @override
  String get homeTalkToLunaWithSparkle => 'Talk to Luna ✨';

  @override
  String get homeThoughtsHint => 'What\'s on your mind today...';

  @override
  String get homeThoughtsEncouragementStart => 'What\'s on your mind... 🌱';

  @override
  String get homeThoughtsEncouragementContinue => 'Keep going...';

  @override
  String get homeThoughtsEncouragementOpeningUp => 'You\'re opening up 🌿';

  @override
  String get homeThoughtsEncouragementBeautiful => 'Beautiful reflection 🌸';

  @override
  String get homeThoughtsEncouragementListening => 'Luna is listening 💜';

  @override
  String get homeRecentEntriesLabel => 'RECENT MEMORIES';

  @override
  String get homeSeeAllLabel => 'View full timeline';

  @override
  String get homeStreakMotivationStart =>
      'Small moments become meaningful habits.';

  @override
  String get homeStreakMotivationActive =>
      'You\'ve shown up for yourself every day.';

  @override
  String get homeStreakMotivationMilestone =>
      'One more day and your plant grows.';

  @override
  String get homeEmptyStateSubtitle => 'Share a thought and tap Talk to Luna';

  @override
  String get homeFirstSeedCelebration => 'You just planted your first seed 🌱';

  @override
  String get homeFirstSeedCelebrationSubtitle =>
      'Luna is so happy you\'re here!';

  @override
  String homeDaysStreakChip(int streak) {
    return '$streak days streak';
  }

  @override
  String get weeklyLetterBannerTitle => 'Your weekly letter';

  @override
  String get weeklyLetterScreenTitle => 'Weekly letter';

  @override
  String get weeklyLetterWaitingMessage =>
      'Keep journaling — your letter will be ready at the end of the week.';

  @override
  String get weeklyLetterShowLess => 'Show less';

  @override
  String get weeklyLetterReadMore => 'Read more';

  @override
  String weeklyLetterEntriesChip(int count) {
    return '$count entries';
  }

  @override
  String weeklyLetterStreakChip(int count) {
    return '🔥 $count day streak';
  }

  @override
  String get journalTitle => 'My Journal';

  @override
  String get journalEmptyStateSubtitle => 'What\'s on your mind today?';

  @override
  String journalDayStreakLabel(int count) {
    return '$count day streak';
  }

  @override
  String get journalStartJournalingButton => 'Start journaling';

  @override
  String get journalEntryDeleteTitle => 'Delete entry?';

  @override
  String get journalEntryDeleteMessage =>
      'This will permanently remove this journal entry.';

  @override
  String get journalSearchHint => 'Search entries...';

  @override
  String get journalCardOptionsColorLabel => 'card color';

  @override
  String get journalCardOptionsPinLabel => 'pin this entry';

  @override
  String get journalCardOptionsDeleteLabel => 'delete entry';

  @override
  String get journalCardOptionsDeleteTitle => 'Delete this entry?';

  @override
  String get journalCardOptionsDeleteMessage =>
      'This will remove it from your journal for good.';

  @override
  String get journalGridTitle => 'your journal';

  @override
  String get journalGridSubtitle => 'a little collection of your days';

  @override
  String get journalEmptyStateTitle => 'No journal yet';

  @override
  String get journalGridEmptyMessage =>
      'Every story begins with a single page.';

  @override
  String get journalTodayNoEntriesMessage =>
      'No entries yet · Start with one gentle thought';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get timelineFilterAllMoods => 'All moods';

  @override
  String get timelineFilterAllMonths => 'All months';

  @override
  String get timelineNoResultsTitle => 'Nothing here yet';

  @override
  String get timelineNoResultsMessage =>
      'Try a different mood, month, or search word.';

  @override
  String get timelineReflection1 => '🌸 Spring brought many hopeful moments.';

  @override
  String get timelineReflection2 =>
      '🌙 You\'ve come a long way since these days.';

  @override
  String get timelineReflection3 =>
      '🍂 Your calmer days are becoming more frequent.';

  @override
  String get timelineReflection4 =>
      '☀️ Every entry here is a small act of showing up.';

  @override
  String get journalMoodFallbackLabel => 'Okay';

  @override
  String get quotesScreenTitle => 'Saved quotes';

  @override
  String get quotesLoadingMessage => 'Loading saved quotes...';

  @override
  String get quotesEmptyTitle => 'No saved quotes yet';

  @override
  String get quotesEmptySubtitle => 'Luna will remember your favorite words.';

  @override
  String get quotesDeleteTitle => 'Delete quote?';

  @override
  String get quotesDeleteMessage => 'This will remove the saved quote.';

  @override
  String get quotesDeletedSnack => 'Quote deleted';

  @override
  String get quotesUndoAction => 'Undo';

  @override
  String get responseTryAgainButton => 'Try again';

  @override
  String get responseShareButton => 'Share';

  @override
  String get responseDoneLabel => 'Done';

  @override
  String get responseKeepChattingLabel => 'Keep chatting';

  @override
  String get responseMoodTagExpressing => 'Expressing';

  @override
  String get responseMoodTagReflecting => 'Reflecting';

  @override
  String get responseMoodTagGrowing => 'Growing';

  @override
  String get responseThinkingLabel => 'Luna is thinking';

  @override
  String get responseShareCardHeading => 'Luna says';

  @override
  String get responseYourMoodLabel => 'YOUR MOOD';

  @override
  String get responseLunaSaysLabel => 'LUNA SAYS';

  @override
  String get responseSaveQuoteTooltip => 'Save quote';

  @override
  String get responseCopiedToClipboardSnack => 'Copied to clipboard 🌿';

  @override
  String get lunaSubtitle => 'Your companion · Always here for you';

  @override
  String get afterFeelingPromptLabel => 'How are you feeling after this?';

  @override
  String get afterFeelingCalmLabel => 'Calm';

  @override
  String get afterFeelingCalmMessage =>
      'Feeling calm is a beautiful shift. You did great.';

  @override
  String get afterFeelingLovedLabel => 'Loved';

  @override
  String get afterFeelingLovedMessage =>
      'You deserve every bit of that love. Hold onto it.';

  @override
  String get afterFeelingBetterLabel => 'Better';

  @override
  String get afterFeelingBetterMessage =>
      'Every small step forward counts. You are making progress.';

  @override
  String get afterFeelingStillSadLabel => 'Still sad';

  @override
  String get afterFeelingStillSadMessage =>
      'It\'s okay to still feel this way. Luna is always here whenever you need to talk again.';

  @override
  String get afterFeelingTakeYourTime => 'Take your time';

  @override
  String get afterFeelingTalkToLunaAgain => 'Talk to Luna again';

  @override
  String get afterFeelingThankYouLuna => 'Thank you, Luna';

  @override
  String get afterFeelingImOkay => 'I\'ll be okay';

  @override
  String get moodChoicePrompt => 'rough day, huh?';

  @override
  String get moodChoiceSubPrompt => 'whatever feels right right now';

  @override
  String get moodChoiceTalkSubtitle => 'share what\'s on your mind';

  @override
  String get moodChoiceBreatheTitle => 'Breathe with Luna';

  @override
  String get moodChoiceBreatheSubtitle => 'a slow, guided breath';

  @override
  String get moodChoiceDrawTitle => 'Free Draw';

  @override
  String get moodChoiceDrawSubtitle => 'no pressure, just color';

  @override
  String get moodChoiceSudokuTitle => 'Sudoku';

  @override
  String get moodChoiceSudokuSubtitle => 'a small, calm puzzle';

  @override
  String get chatInputHint => 'Share what\'s on your mind...';

  @override
  String get chatEmptyStateMessage =>
      'Hi, I\'m Luna 💜\nTell me how you\'re feeling.';

  @override
  String get chatTypingLabel => 'Luna is typing';

  @override
  String get chatSessionEndGladMessage => 'I\'m glad you\'re feeling better 💜';

  @override
  String get chatSessionEndSavedMessage =>
      'This session has been saved to your journal.';

  @override
  String get chatBackToHomeButton => 'Back to Home';

  @override
  String get sudokuHowToPlayTitle => 'How to play';

  @override
  String get sudokuHowToPlayMessage =>
      'Fill every row, column, and 3x3 box with the digits 1-9, no repeats. Switch to Candidate mode to pencil in notes, and turn on Auto Candidate Mode to have Luna clear out notes for you as you go.';

  @override
  String get sudokuGotIt => 'Got it';

  @override
  String get sudokuNewGameMenuItem => 'New game';

  @override
  String get sudokuDifficultyEasy => 'Easy';

  @override
  String sudokuMistakesLabel(int mistakes, int max) {
    return 'Mistakes: $mistakes/$max';
  }

  @override
  String get sudokuPausedLabel => 'paused';

  @override
  String get sudokuWonMessage => 'you solved it! 🌸';

  @override
  String get sudokuDoneButton => 'done';

  @override
  String get sudokuPlayAgainButton => 'play again';

  @override
  String get sudokuLostMessage => 'out of tries — take a breath 🌱';

  @override
  String get sudokuTryAgainButton => 'try again';

  @override
  String get sudokuAutoCandidateModeLabel => 'Auto Candidate Mode';

  @override
  String get sudokuNormalModeLabel => 'Normal';

  @override
  String get sudokuCandidateModeLabel => 'Candidate';

  @override
  String get drawTopBarTitle => 'free draw';

  @override
  String get drawUndoButton => 'undo';

  @override
  String get drawClearButton => 'clear';

  @override
  String get drawSavedSnack => 'Drawing saved to your profile';

  @override
  String get drawTalkToLunaLink => 'feel like talking to luna now?';

  @override
  String get drawViewerTitle => 'your drawing';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileSubtitle => 'Lueur member';

  @override
  String get profileFallbackName => 'Friend';

  @override
  String get profileQuotesEmptySubtitle =>
      'Luna will remember your favorite words.';

  @override
  String get profileStatsTotalEntries => 'Total entries';

  @override
  String get profileStatsDayStreak => 'Day streak';

  @override
  String get profileStatsSectionLabel => 'STATISTICS';

  @override
  String get profileQuickLinksSectionLabel => 'MORE';

  @override
  String get profileQuickLinkWeeklyLetter => 'Weekly Letter';

  @override
  String get profileQuickLinkMoodBoard => 'Mood Board';

  @override
  String get profileSettingsSectionLabel => 'SETTINGS';

  @override
  String get profileSettingsAppearance => 'Appearance';

  @override
  String get profileSettingsLanguage => 'Language';

  @override
  String get profileDrawingsTitle => 'My Drawings';

  @override
  String get profileDrawingsErrorSubtitle =>
      'Couldn\'t load your drawings — pull to refresh and try again';

  @override
  String get profileDrawingsEmptySubtitle => 'Your creativity has a home here.';

  @override
  String get profileSudokuHistoryTitle => 'Sudoku History';

  @override
  String get profileSudokuHistoryErrorSubtitle =>
      'Couldn\'t load your Sudoku history — pull to refresh and try again';

  @override
  String get profileSudokuHistoryEmptySubtitle =>
      'Play a round of Sudoku to see your results here';

  @override
  String get profileSudokuRelativeToday => 'Today';

  @override
  String get profileSudokuRelativeYesterday => 'Yesterday';

  @override
  String get profileSudokuSolvedIt => 'Solved it';

  @override
  String get profileSudokuGaveItAGo => 'Gave it a go';

  @override
  String get breathingHeaderLabel => 'guided breathing';

  @override
  String get breathingPhaseIn => 'Breathe in';

  @override
  String get breathingPhaseOut => 'Breathe out';

  @override
  String get affirmationHeader => 'A word from Luna 💙';

  @override
  String get affirmationSubheader => 'A personalized card just for you';

  @override
  String get affirmationSignature => '— Luna 🌿';

  @override
  String get affirmationNextCardButton => 'Next card ↻';

  @override
  String get affirmationPrimaryStartBreathing => 'Start breathing';

  @override
  String get affirmationPrimaryStartDrawing => 'Start drawing';

  @override
  String get affirmationPrimaryPlaySudoku => 'Play Sudoku';

  @override
  String get lunaCheckInTitle => 'Feel a little lighter?';

  @override
  String get lunaCheckInSubtitle => 'I\'m here if you want to talk more.';

  @override
  String get lunaCheckInDismiss => 'I\'m good for now';

  @override
  String get streakCelebrationKeepGoingButton => 'keep going';

  @override
  String get chatSendFailedMessages0 => 'hmm that didn\'t send, try again?';

  @override
  String get chatSendFailedMessages1 =>
      'ugh my signal\'s being weird, say that again?';

  @override
  String get chatSendFailedMessages2 => 'wait that got cut off, one more time?';

  @override
  String get chatSendFailedMessages3 =>
      'hold on, didn\'t catch that — try sending again';

  @override
  String get chatSendFailedMessages4 =>
      'hmm something glitched, can you resend that?';

  @override
  String get streakCelebrationAffirmations0 =>
      'A whole week of showing up for yourself. Luna noticed 🌸';

  @override
  String get streakCelebrationAffirmations1 =>
      'Seven days of choosing yourself, one thought at a time.';

  @override
  String get streakCelebrationAffirmations2 =>
      'You kept coming back — that\'s the whole secret, really.';

  @override
  String get streakCelebrationAffirmations3 =>
      'Luna is so glad you\'re still here, day after day.';

  @override
  String get streakCelebrationAffirmations4 =>
      'This is what taking care of you looks like. Keep it up.';

  @override
  String get streakCelebrationAffirmations5 =>
      'A full week, gently and honestly. That\'s worth celebrating.';

  @override
  String streakCelebrationNextMilestone(int days) {
    return '$days days until your next milestone';
  }

  @override
  String get streakCelebrationAllMilestonesReached =>
      'You\'ve reached every milestone — Luna is in awe';

  @override
  String get streakCelebrationEyebrowLabel => 'Streak days';

  @override
  String get streakCelebrationProgressSemanticLabel =>
      'Progress toward your next milestone';

  @override
  String get streakGrowthStageSeedLabel => 'Seed 🌱';

  @override
  String get streakGrowthStageSproutLabel => 'Sprout 🌿';

  @override
  String get streakGrowthStagePlantLabel => 'Growing 🪴';

  @override
  String get streakGrowthStageBloomingLabel => 'Blooming 🌸';

  @override
  String get authSuccessTitle => 'You\'re in!';

  @override
  String get authSuccessMessage => 'Luna\'s glad you\'re here.';
}
