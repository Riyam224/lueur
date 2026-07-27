/// App-wide string constants shared across features
class AppStrings {
  // splash
  static const String appName = 'Lueur';
  static const String appTagline = 'a little light for you';
  // onboarding
  static const String onboardingSkip = 'Skip intro';
  static const String onboardingGetStarted = 'Get started';

  static const String onboardingTitle1 = 'A gentle space,\njust for you';
  static const String onboardingSubtitle1 =
      'Check in with how you\'re feeling —\nno pressure, just presence.';

  static const String onboardingTitle2 = 'Meet Luna,\nyour companion';
  static const String onboardingSubtitle2 =
      'She\'s here to listen whenever\nyou need to talk it out.';

  static const String onboardingTitle3 = 'Small steps,\nreal growth';
  static const String onboardingSubtitle3 =
      'Show up for yourself each day and\nwatch something beautiful grow.';

  // auth — login
  static const String loginWelcomeBack = 'Welcome back';
  static const String loginSubtitle = 'Luna missed you';
  static const String loginCta = 'Talk to Luna';
  static const String loginSignUpPrompt = "Don't have an account? ";
  static const String loginSignUpAction = 'Start growing';

  // auth — register
  static const String registerTitle = 'Start your journey';
  static const String registerSubtitle = 'Luna is ready to listen';
  static const String registerCta = 'Begin growing';
  static const String registerSignInPrompt = 'Already have an account? ';
  static const String registerSignInAction = 'Sign in';

  // auth — guest & session actions
  static const String authContinueAsGuest = 'Continue as guest';
  static const String authLogOut = 'Log out';

  // auth — shared fields
  static const String authEmailLabel = 'Email';
  static const String authEmailHint = 'your@email.com';
  static const String authPasswordLabel = 'Password';
  static const String authPasswordHint = '••••••••';
  static const String authFullNameLabel = 'Full name';
  static const String authFullNameHint = 'Your name';
  static const String authForgotPassword = 'Forgot password?';
  static const String authOrDivider = 'or';

  // auth — forgot password
  static const String forgotPasswordTitle = 'Reset your password';
  static const String forgotPasswordSubtitle =
      'Enter your email and Luna will send you a link to get back in.';
  static const String forgotPasswordCta = 'Send reset link';
  static const String forgotPasswordEmailRequired = 'Please enter your email';
  static const String forgotPasswordSuccessTitle = 'Check your email';
  static const String forgotPasswordSuccessSubtitle =
      'We sent a password reset link to your email. Follow it to set a new password.';
  static const String forgotPasswordBackToLogin = 'Back to login';
  static const String authContinueWithGoogle = 'Continue with Google';
  static const String authSignUpWithGoogle = 'Sign up with Google';

  // auth — password strength
  static const String passwordStrengthTooShort = 'Too short';
  static const String passwordStrengthGettingThere = 'Getting there';
  static const String passwordStrengthStrong = 'Strong';

  // home — mood type gallery
  static const String homeMoodGalleryTitle = 'EXPLORE MOODS';

  static const String moodLabelHappy = 'Happy';
  static const String moodLabelSad = 'Sad';
  static const String moodLabelAngry = 'Angry';
  static const String moodLabelAnxious = 'Anxious';
  static const String moodLabelCalm = 'Calm';
  static const String moodLabelExcited = 'Excited';
  static const String moodLabelGrateful = 'Grateful';
  static const String moodLabelHopeful = 'Hopeful';
  static const String moodLabelLonely = 'Lonely';
  static const String moodLabelNeutral = 'Neutral';
  static const String moodLabelScared = 'Scared';
  static const String moodLabelBurnout = 'Burnt out';
  static const String moodLabelContentPeaceful = 'Content & Peaceful';

  // ── Common (shared across dialogs/screens) ──
  static const String commonCancel = 'Cancel';
  static const String commonDelete = 'Delete';
  static const String commonTalkToLuna = 'Talk to Luna';
  static const String commonThisWeekLabel = 'This week';
  static const String commonSavedToQuotesSnack = 'Saved to quotes 🌿';
  static const String commonDismissBarrierLabel = 'Dismiss';
  static const String lunaName = 'Luna';

  // ── Bottom navigation ──
  static const String navHomeLabel = 'Home';
  static const String navJournalLabel = 'Journal';
  static const String navProfileLabel = 'Profile';

  // ── Mood entries (shared: home + journal) ──
  static const String moodEntryDeleteAllTitle = 'Delete all entries?';
  static const String moodEntryDeleteAllMessage =
      'This will permanently remove all journal entries from your device.';
  static const String moodEntryDeleteAllConfirm = 'Delete all';
  static const String moodEntryEmptyStateTitle = 'Your story starts here';
  static const String moodEntryListEmptyMessage = 'No mood entries yet';

  // ── Home ──
  static const String homeMoodPromptLabel = 'How are you feeling today?';
  static const String homeThoughtsLabelSad = 'What\'s weighing on you?';
  static const String homeThoughtsLabelLonely = 'What\'s been on your mind?';
  static const String homeThoughtsLabelAngry = 'What set this off?';
  static const String homeThoughtsLabelWorried = 'What\'s worrying you?';
  static const String homeThoughtsLabelBurnout = 'What\'s been draining you?';
  static const String homeThoughtsLabelNeutralGood = 'What\'s going on today?';
  static const String homeThoughtsLabelFeelGood =
      'What\'s making you feel good?';
  static const String homeThoughtsLabelGrateful = 'What are you grateful for?';
  static const String homeThoughtsLabelHopeful =
      'What are you looking forward to?';
  static const String homeThoughtsLabelDefault = 'Tell me what\'s going on...';
  static const String homeMoodRequiredSnack = 'Please select your mood first';
  static const String homeThoughtsRequiredSnack = 'Please share your thoughts';
  static const String homeThoughtsHint = 'What\'s on your mind today...';
  static const String homeThoughtsEncouragementStart =
      'What\'s on your mind... 🌱';
  static const String homeThoughtsEncouragementContinue = 'Keep going...';
  static const String homeThoughtsEncouragementOpeningUp =
      'You\'re opening up 🌿';
  static const String homeThoughtsEncouragementBeautiful =
      'Beautiful reflection 🌸';
  static const String homeThoughtsEncouragementListening =
      'Luna is listening 💜';
  static const String homeRecentEntriesLabel = 'RECENT ENTRIES';
  static const String homeSeeAllLabel = 'See all';
  static const String homeEmptyStateSubtitle =
      'Share a thought and tap Talk to Luna';
  static const String homeFirstSeedCelebration =
      'You just planted your first seed 🌱';

  // ── Weekly letter ──
  static const String weeklyLetterBannerTitle = 'Your weekly letter';
  static const String weeklyLetterScreenTitle = 'Weekly letter';
  static const String weeklyLetterWaitingMessage =
      'Keep journaling — your letter will be ready at the end of the week.';
  static const String weeklyLetterShowLess = 'Show less';
  static const String weeklyLetterReadMore = 'Read more';

  // ── Journal ──
  static const String journalTitle = 'My Journal';
  static const String journalEmptyStateSubtitle = 'What\'s on your mind today?';
  static const String journalStartJournalingButton = 'Start journaling';
  static const String journalEntryDeleteTitle = 'Delete entry?';
  static const String journalEntryDeleteMessage =
      'This will permanently remove this journal entry.';
  static const String journalSearchHint = 'Search entries...';
  static const String journalCardOptionsColorLabel = 'card color';
  static const String journalCardOptionsPinLabel = 'pin this entry';
  static const String journalCardOptionsDeleteLabel = 'delete entry';
  static const String journalCardOptionsDeleteTitle = 'Delete this entry?';
  static const String journalCardOptionsDeleteMessage =
      'This will remove it from your journal for good.';
  static const String journalGridTitle = 'your journal';
  static const String journalGridSubtitle = 'a little collection of your days';
  static const String journalGridEmptyMessage =
      'nothing here yet — your days will show up as you go';
  static const String journalTodayNoEntriesMessage =
      'No entries yet · Start with one gentle thought';
  static const String journalMoodFallbackLabel = 'Okay';

  // ── Saved quotes ──
  static const String quotesScreenTitle = 'Saved quotes';
  static const String quotesLoadingMessage = 'Loading saved quotes...';
  static const String quotesEmptyTitle = 'No saved quotes yet';
  static const String quotesEmptySubtitle =
      'Save Luna’s words to collect them here';
  static const String quotesDeleteTitle = 'Delete quote?';
  static const String quotesDeleteMessage = 'This will remove the saved quote.';
  static const String quotesDeletedSnack = 'Quote deleted';
  static const String quotesUndoAction = 'Undo';

  // ── Response (Luna's reply screen) ──
  static const String responseTryAgainButton = 'Try again';
  static const String responseShareButton = 'Share';
  static const String responseDoneLabel = 'Done';
  static const String responseKeepChattingLabel = 'Keep chatting';
  static const String responseMoodTagExpressing = 'Expressing';
  static const String responseMoodTagReflecting = 'Reflecting';
  static const String responseMoodTagGrowing = 'Growing';
  static const String responseThinkingLabel = 'Luna is thinking';
  static const String responseShareCardHeading = 'Luna says';
  static const String responseYourMoodLabel = 'YOUR MOOD';
  static const String responseLunaSaysLabel = 'LUNA SAYS';
  static const String responseSaveQuoteTooltip = 'Save quote';
  static const String responseCopiedToClipboardSnack = 'Copied to clipboard 🌿';
  static const String lunaSubtitle = 'Your companion · Always here for you';

  // ── After-feeling selector ──
  static const String afterFeelingPromptLabel =
      'How are you feeling after this?';
  static const String afterFeelingCalmLabel = 'Calm';
  static const String afterFeelingCalmMessage =
      'Feeling calm is a beautiful shift. You did great.';
  static const String afterFeelingLovedLabel = 'Loved';
  static const String afterFeelingLovedMessage =
      'You deserve every bit of that love. Hold onto it.';
  static const String afterFeelingBetterLabel = 'Better';
  static const String afterFeelingBetterMessage =
      'Every small step forward counts. You are making progress.';
  static const String afterFeelingStillSadLabel = 'Still sad';
  static const String afterFeelingStillSadMessage =
      'It\'s okay to still feel this way. Luna is always here whenever you '
      'need to talk again.';
  static const String afterFeelingTakeYourTime = 'Take your time';
  static const String afterFeelingTalkToLunaAgain = 'Talk to Luna again';
  static const String afterFeelingThankYouLuna = 'Thank you, Luna';
  static const String afterFeelingImOkay = 'I\'ll be okay';

  // ── Mood choice dialog ──
  static const String moodChoicePrompt = 'rough day, huh?';
  static const String moodChoiceSubPrompt = 'whatever feels right right now';
  static const String moodChoiceTalkSubtitle = 'share what\'s on your mind';
  static const String moodChoiceBreatheTitle = 'Breathe with Luna';
  static const String moodChoiceBreatheSubtitle = 'a slow, guided breath';
  static const String moodChoiceDrawTitle = 'Free Draw';
  static const String moodChoiceDrawSubtitle = 'no pressure, just color';
  static const String moodChoiceSudokuTitle = 'Sudoku';
  static const String moodChoiceSudokuSubtitle = 'a small, calm puzzle';

  // ── Chat ──
  static const String chatInputHint = 'Share what\'s on your mind...';
  static const String chatEmptyStateMessage =
      'Hi, I\'m Luna 💜\nTell me how you\'re feeling.';
  static const String chatTypingLabel = 'Luna is typing';
  static const String chatSessionEndGladMessage =
      'I\'m glad you\'re feeling better 💜';
  static const String chatSessionEndSavedMessage =
      'This session has been saved to your journal.';
  static const String chatBackToHomeButton = 'Back to Home';
  static const List<String> chatSendFailedMessages = [
    'hmm that didn\'t send, try again?',
    'ugh my signal\'s being weird, say that again?',
    'wait that got cut off, one more time?',
    'hold on, didn\'t catch that — try sending again',
    'hmm something glitched, can you resend that?',
  ];

  // ── Sudoku ──
  static const String sudokuHowToPlayTitle = 'How to play';
  static const String sudokuHowToPlayMessage =
      'Fill every row, column, and 3x3 box with the digits 1-9, '
      'no repeats. Switch to Candidate mode to pencil in notes, and '
      'turn on Auto Candidate Mode to have Luna clear out notes for '
      'you as you go.';
  static const String sudokuGotIt = 'Got it';
  static const String sudokuNewGameMenuItem = 'New game';
  static const String sudokuDifficultyEasy = 'Easy';
  static const String sudokuPausedLabel = 'paused';
  static const String sudokuWonMessage = 'you solved it! 🌸';
  static const String sudokuDoneButton = 'done';
  static const String sudokuPlayAgainButton = 'play again';
  static const String sudokuLostMessage = 'out of tries — take a breath 🌱';
  static const String sudokuTryAgainButton = 'try again';
  static const String sudokuAutoCandidateModeLabel = 'Auto Candidate Mode';

  // ── Free draw ──
  static const String drawTopBarTitle = 'free draw';
  static const String drawClearButton = 'clear';
  static const String drawSavedSnack = 'Drawing saved to your profile';
  static const String drawTalkToLunaLink = 'feel like talking to luna now?';
  static const String drawViewerTitle = 'your drawing';

  // ── Profile ──
  static const String profileTitle = 'My Profile';
  static const String profileSubtitle = 'Lueur member';
  static const String profileFallbackName = 'Friend';
  static const String profileQuotesEmptySubtitle =
      'Your saved Luna moments will appear here';
  static const String profileStatsTotalEntries = 'Total entries';
  static const String profileStatsDayStreak = 'Day streak';
  static const String profileQuickLinkWeeklyLetter = 'Weekly Letter';
  static const String profileQuickLinkMoodBoard = 'Mood Board';
  static const String profileSettingsSectionLabel = 'SETTINGS';
  static const String profileSettingsAppearance = 'Appearance';
  static const String profileDrawingsTitle = 'My Drawings';
  static const String profileDrawingsErrorSubtitle =
      'Couldn\'t load your drawings — pull to refresh and try again';
  static const String profileDrawingsEmptySubtitle =
      'Drawings you save from Free Draw will appear here';
  static const String profileSudokuHistoryTitle = 'Sudoku History';
  static const String profileSudokuHistoryErrorSubtitle =
      'Couldn\'t load your Sudoku history — pull to refresh and try again';
  static const String profileSudokuHistoryEmptySubtitle =
      'Play a round of Sudoku to see your results here';
  static const String profileSudokuRelativeToday = 'Today';
  static const String profileSudokuRelativeYesterday = 'Yesterday';
  static const String profileSudokuSolvedIt = 'Solved it';
  static const String profileSudokuGaveItAGo = 'Gave it a go';
}
