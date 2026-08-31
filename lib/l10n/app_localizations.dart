import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Lueur'**
  String get appName;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @responseScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Luna\'s Response'**
  String get responseScreenTitle;

  /// No description provided for @streakDaysWithLuna.
  ///
  /// In en, this message translates to:
  /// **'{days} days with Luna 🌸'**
  String streakDaysWithLuna(int days);

  /// No description provided for @homeGreetingMessage.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name} 🌙 {streak} days strong — I\'m proud of you.'**
  String homeGreetingMessage(String name, int streak);

  /// No description provided for @homeGreetingNoEntries.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}, I\'m Luna. I\'m here whenever you\'re ready to talk 🌱'**
  String homeGreetingNoEntries(String name);

  /// No description provided for @homeGreetingMorningStreak.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}! {streak}-day streak — that\'s beautiful 🌸'**
  String homeGreetingMorningStreak(String name, int streak);

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name} ☀️ What\'s on your heart today?'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Hey {name} 🌤️ How\'s your day going so far?'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEveningNoStreak.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name} 🌙 I\'m here if you want to talk.'**
  String homeGreetingEveningNoStreak(String name);

  /// No description provided for @homeGreetingLateNight.
  ///
  /// In en, this message translates to:
  /// **'Hey {name} ⭐ Still up? I\'m listening.'**
  String homeGreetingLateNight(String name);

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'a little light for you'**
  String get appTagline;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip intro'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'A gentle space,\njust for you'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Check in with how you\'re feeling —\nno pressure, just presence.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Meet Luna,\nyour companion'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'A friendly journaling companion for\nreflection, not professional guidance.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Small steps,\nreal growth'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Show up for yourself each day and\nwatch something beautiful grow.'**
  String get onboardingSubtitle3;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luna missed you'**
  String get loginSubtitle;

  /// No description provided for @loginCta.
  ///
  /// In en, this message translates to:
  /// **'Talk to Luna'**
  String get loginCta;

  /// No description provided for @loginSignUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginSignUpPrompt;

  /// No description provided for @loginSignUpAction.
  ///
  /// In en, this message translates to:
  /// **'Start growing'**
  String get loginSignUpAction;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luna is ready to listen'**
  String get registerSubtitle;

  /// No description provided for @registerCta.
  ///
  /// In en, this message translates to:
  /// **'Begin growing'**
  String get registerCta;

  /// No description provided for @registerSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerSignInPrompt;

  /// No description provided for @registerSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignInAction;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @guestWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'A quick heads-up'**
  String get guestWarningTitle;

  /// No description provided for @guestWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'As a guest, Luna won\'t remember your entries once you close the app. Want to keep your streak growing? You can register anytime.'**
  String get guestWarningMessage;

  /// No description provided for @guestWarningRegisterInstead.
  ///
  /// In en, this message translates to:
  /// **'Register instead'**
  String get guestWarningRegisterInstead;

  /// No description provided for @authLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogOut;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get authFullNameHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and Luna will send you a link to get back in.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordCta;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to your email. Follow it to set a new password.'**
  String get forgotPasswordSuccessSubtitle;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authSignUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get authSignUpWithGoogle;

  /// No description provided for @passwordStrengthTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get passwordStrengthTooShort;

  /// No description provided for @passwordStrengthGettingThere.
  ///
  /// In en, this message translates to:
  /// **'Getting there'**
  String get passwordStrengthGettingThere;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get authConfirmPasswordMismatch;

  /// No description provided for @authFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get authFieldRequired;

  /// No description provided for @homeMoodGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE MOODS'**
  String get homeMoodGalleryTitle;

  /// No description provided for @moodLabelHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodLabelHappy;

  /// No description provided for @moodLabelSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodLabelSad;

  /// No description provided for @moodLabelAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodLabelAngry;

  /// No description provided for @moodLabelAnxious.
  ///
  /// In en, this message translates to:
  /// **'Uneasy'**
  String get moodLabelAnxious;

  /// No description provided for @moodLabelCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodLabelCalm;

  /// No description provided for @moodLabelExcited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get moodLabelExcited;

  /// No description provided for @moodLabelGrateful.
  ///
  /// In en, this message translates to:
  /// **'Grateful'**
  String get moodLabelGrateful;

  /// No description provided for @moodLabelHopeful.
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get moodLabelHopeful;

  /// No description provided for @moodLabelLonely.
  ///
  /// In en, this message translates to:
  /// **'Lonely'**
  String get moodLabelLonely;

  /// No description provided for @moodLabelNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodLabelNeutral;

  /// No description provided for @moodLabelScared.
  ///
  /// In en, this message translates to:
  /// **'Scared'**
  String get moodLabelScared;

  /// No description provided for @moodLabelBurnout.
  ///
  /// In en, this message translates to:
  /// **'Drained'**
  String get moodLabelBurnout;

  /// No description provided for @moodLabelContentPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Content & Peaceful'**
  String get moodLabelContentPeaceful;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonTalkToLuna.
  ///
  /// In en, this message translates to:
  /// **'Talk to Luna'**
  String get commonTalkToLuna;

  /// No description provided for @commonThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get commonThisWeekLabel;

  /// No description provided for @commonSavedToQuotesSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved to quotes 🌿'**
  String get commonSavedToQuotesSnack;

  /// No description provided for @commonDismissBarrierLabel.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismissBarrierLabel;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @lunaName.
  ///
  /// In en, this message translates to:
  /// **'Luna'**
  String get lunaName;

  /// No description provided for @navHomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeLabel;

  /// No description provided for @navJournalLabel.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournalLabel;

  /// No description provided for @navProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfileLabel;

  /// No description provided for @moodEntryDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all entries?'**
  String get moodEntryDeleteAllTitle;

  /// No description provided for @moodEntryDeleteAllMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all journal entries from your device.'**
  String get moodEntryDeleteAllMessage;

  /// No description provided for @moodEntryDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get moodEntryDeleteAllConfirm;

  /// No description provided for @moodEntryEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Your story starts here'**
  String get moodEntryEmptyStateTitle;

  /// No description provided for @moodEntryListEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No mood entries yet'**
  String get moodEntryListEmptyMessage;

  /// No description provided for @homeMoodPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get homeMoodPromptLabel;

  /// No description provided for @homeThoughtsLabelSad.
  ///
  /// In en, this message translates to:
  /// **'What\'s weighing on you?'**
  String get homeThoughtsLabelSad;

  /// No description provided for @homeThoughtsLabelLonely.
  ///
  /// In en, this message translates to:
  /// **'What\'s been on your mind?'**
  String get homeThoughtsLabelLonely;

  /// No description provided for @homeThoughtsLabelAngry.
  ///
  /// In en, this message translates to:
  /// **'What set this off?'**
  String get homeThoughtsLabelAngry;

  /// No description provided for @homeThoughtsLabelWorried.
  ///
  /// In en, this message translates to:
  /// **'What\'s worrying you?'**
  String get homeThoughtsLabelWorried;

  /// No description provided for @homeThoughtsLabelBurnout.
  ///
  /// In en, this message translates to:
  /// **'What\'s been draining you?'**
  String get homeThoughtsLabelBurnout;

  /// No description provided for @homeThoughtsLabelNeutralGood.
  ///
  /// In en, this message translates to:
  /// **'What\'s going on today?'**
  String get homeThoughtsLabelNeutralGood;

  /// No description provided for @homeThoughtsLabelFeelGood.
  ///
  /// In en, this message translates to:
  /// **'What\'s making you feel good?'**
  String get homeThoughtsLabelFeelGood;

  /// No description provided for @homeThoughtsLabelGrateful.
  ///
  /// In en, this message translates to:
  /// **'What are you grateful for?'**
  String get homeThoughtsLabelGrateful;

  /// No description provided for @homeThoughtsLabelHopeful.
  ///
  /// In en, this message translates to:
  /// **'What are you looking forward to?'**
  String get homeThoughtsLabelHopeful;

  /// No description provided for @homeThoughtsLabelDefault.
  ///
  /// In en, this message translates to:
  /// **'Tell me what\'s going on...'**
  String get homeThoughtsLabelDefault;

  /// No description provided for @homeMoodRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Please select your mood first'**
  String get homeMoodRequiredSnack;

  /// No description provided for @homeThoughtsRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Please share your thoughts'**
  String get homeThoughtsRequiredSnack;

  /// No description provided for @homeThoughtsRequiredSnackFirst.
  ///
  /// In en, this message translates to:
  /// **'Please share your thoughts first'**
  String get homeThoughtsRequiredSnackFirst;

  /// No description provided for @homeShareThoughtsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SHARE YOUR THOUGHTS'**
  String get homeShareThoughtsSectionLabel;

  /// No description provided for @homeTalkToLunaWithSparkle.
  ///
  /// In en, this message translates to:
  /// **'Talk to Luna ✨'**
  String get homeTalkToLunaWithSparkle;

  /// No description provided for @homeThoughtsHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind today...'**
  String get homeThoughtsHint;

  /// No description provided for @homeThoughtsEncouragementStart.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind... 🌱'**
  String get homeThoughtsEncouragementStart;

  /// No description provided for @homeThoughtsEncouragementContinue.
  ///
  /// In en, this message translates to:
  /// **'Keep going...'**
  String get homeThoughtsEncouragementContinue;

  /// No description provided for @homeThoughtsEncouragementOpeningUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re opening up 🌿'**
  String get homeThoughtsEncouragementOpeningUp;

  /// No description provided for @homeThoughtsEncouragementBeautiful.
  ///
  /// In en, this message translates to:
  /// **'Beautiful reflection 🌸'**
  String get homeThoughtsEncouragementBeautiful;

  /// No description provided for @homeThoughtsEncouragementListening.
  ///
  /// In en, this message translates to:
  /// **'Luna is listening 💜'**
  String get homeThoughtsEncouragementListening;

  /// No description provided for @homeRecentEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent memories'**
  String get homeRecentEntriesLabel;

  /// No description provided for @homeSeeAllLabel.
  ///
  /// In en, this message translates to:
  /// **'View full timeline'**
  String get homeSeeAllLabel;

  /// No description provided for @homeStreakMotivationStart.
  ///
  /// In en, this message translates to:
  /// **'Small moments become meaningful habits.'**
  String get homeStreakMotivationStart;

  /// No description provided for @homeStreakMotivationActive.
  ///
  /// In en, this message translates to:
  /// **'You\'ve shown up for yourself every day.'**
  String get homeStreakMotivationActive;

  /// No description provided for @homeStreakMotivationMilestone.
  ///
  /// In en, this message translates to:
  /// **'One more day and your plant grows.'**
  String get homeStreakMotivationMilestone;

  /// No description provided for @homeEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a thought and tap Talk to Luna'**
  String get homeEmptyStateSubtitle;

  /// No description provided for @homeFirstSeedCelebration.
  ///
  /// In en, this message translates to:
  /// **'You just planted your first seed 🌱'**
  String get homeFirstSeedCelebration;

  /// No description provided for @homeFirstSeedCelebrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luna is so happy you\'re here!'**
  String get homeFirstSeedCelebrationSubtitle;

  /// No description provided for @homeDaysStreakChip.
  ///
  /// In en, this message translates to:
  /// **'{streak} days streak'**
  String homeDaysStreakChip(int streak);

  /// No description provided for @homeNextMilestoneHint.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{1 more day to {milestone} 🌱} other{{days} more days to {milestone} 🌱}}'**
  String homeNextMilestoneHint(int days, int milestone);

  /// No description provided for @weeklyLetterBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weekly letter'**
  String get weeklyLetterBannerTitle;

  /// No description provided for @weeklyLetterScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly letter'**
  String get weeklyLetterScreenTitle;

  /// No description provided for @weeklyLetterWaitingMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep journaling — your letter will be ready at the end of the week.'**
  String get weeklyLetterWaitingMessage;

  /// No description provided for @weeklyLetterErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your letter couldn\'t load. Check your connection and try again.'**
  String get weeklyLetterErrorMessage;

  /// No description provided for @weeklyLetterRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry weekly letter'**
  String get weeklyLetterRetry;

  /// No description provided for @weeklyLetterShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get weeklyLetterShowLess;

  /// No description provided for @weeklyLetterReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get weeklyLetterReadMore;

  /// No description provided for @weeklyLetterEntriesChip.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String weeklyLetterEntriesChip(int count);

  /// No description provided for @weeklyLetterStreakChip.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count} day streak'**
  String weeklyLetterStreakChip(int count);

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'My Journal'**
  String get journalTitle;

  /// No description provided for @journalEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind today?'**
  String get journalEmptyStateSubtitle;

  /// No description provided for @journalDayStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String journalDayStreakLabel(int count);

  /// No description provided for @journalStartJournalingButton.
  ///
  /// In en, this message translates to:
  /// **'Start journaling'**
  String get journalStartJournalingButton;

  /// No description provided for @journalEntryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get journalEntryDeleteTitle;

  /// No description provided for @journalEntryDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this journal entry.'**
  String get journalEntryDeleteMessage;

  /// No description provided for @journalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search entries...'**
  String get journalSearchHint;

  /// No description provided for @journalCardOptionsColorLabel.
  ///
  /// In en, this message translates to:
  /// **'card color'**
  String get journalCardOptionsColorLabel;

  /// No description provided for @journalCardOptionsPinLabel.
  ///
  /// In en, this message translates to:
  /// **'pin this entry'**
  String get journalCardOptionsPinLabel;

  /// No description provided for @journalCardOptionsDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'delete entry'**
  String get journalCardOptionsDeleteLabel;

  /// No description provided for @journalCardOptionsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get journalCardOptionsDeleteTitle;

  /// No description provided for @journalCardOptionsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove it from your journal for good.'**
  String get journalCardOptionsDeleteMessage;

  /// No description provided for @journalGridTitle.
  ///
  /// In en, this message translates to:
  /// **'your journal'**
  String get journalGridTitle;

  /// No description provided for @journalGridSubtitle.
  ///
  /// In en, this message translates to:
  /// **'a little collection of your days'**
  String get journalGridSubtitle;

  /// No description provided for @journalEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No journal yet'**
  String get journalEmptyStateTitle;

  /// No description provided for @journalGridEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Every story begins with a single page.'**
  String get journalGridEmptyMessage;

  /// No description provided for @journalTodayNoEntriesMessage.
  ///
  /// In en, this message translates to:
  /// **'No entries yet · Start with one gentle thought'**
  String get journalTodayNoEntriesMessage;

  /// No description provided for @timelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTitle;

  /// No description provided for @timelineFilterAllMoods.
  ///
  /// In en, this message translates to:
  /// **'All moods'**
  String get timelineFilterAllMoods;

  /// No description provided for @timelineFilterAllMonths.
  ///
  /// In en, this message translates to:
  /// **'All months'**
  String get timelineFilterAllMonths;

  /// No description provided for @timelineNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get timelineNoResultsTitle;

  /// No description provided for @timelineNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different mood, month, or search word.'**
  String get timelineNoResultsMessage;

  /// No description provided for @timelineReflection1.
  ///
  /// In en, this message translates to:
  /// **'🌸 Spring brought many hopeful moments.'**
  String get timelineReflection1;

  /// No description provided for @timelineReflection2.
  ///
  /// In en, this message translates to:
  /// **'🌙 You\'ve come a long way since these days.'**
  String get timelineReflection2;

  /// No description provided for @timelineReflection3.
  ///
  /// In en, this message translates to:
  /// **'🍂 Your calmer days are becoming more frequent.'**
  String get timelineReflection3;

  /// No description provided for @timelineReflection4.
  ///
  /// In en, this message translates to:
  /// **'☀️ Every entry here is a small act of showing up.'**
  String get timelineReflection4;

  /// No description provided for @journalMoodFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get journalMoodFallbackLabel;

  /// No description provided for @journalActivityBreathing.
  ///
  /// In en, this message translates to:
  /// **'took a breather'**
  String get journalActivityBreathing;

  /// No description provided for @journalActivityPuzzle.
  ///
  /// In en, this message translates to:
  /// **'played a puzzle'**
  String get journalActivityPuzzle;

  /// No description provided for @journalActivityDrawing.
  ///
  /// In en, this message translates to:
  /// **'made a little drawing'**
  String get journalActivityDrawing;

  /// No description provided for @quotesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved quotes'**
  String get quotesScreenTitle;

  /// No description provided for @quotesLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading saved quotes...'**
  String get quotesLoadingMessage;

  /// No description provided for @quotesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved quotes yet'**
  String get quotesEmptyTitle;

  /// No description provided for @quotesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luna will remember your favorite words.'**
  String get quotesEmptySubtitle;

  /// No description provided for @quotesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete quote?'**
  String get quotesDeleteTitle;

  /// No description provided for @quotesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove the saved quote.'**
  String get quotesDeleteMessage;

  /// No description provided for @quotesDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Quote deleted'**
  String get quotesDeletedSnack;

  /// No description provided for @quotesUndoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get quotesUndoAction;

  /// No description provided for @responseTryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get responseTryAgainButton;

  /// No description provided for @responseShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get responseShareButton;

  /// No description provided for @responseDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get responseDoneLabel;

  /// No description provided for @responseKeepChattingLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep chatting'**
  String get responseKeepChattingLabel;

  /// No description provided for @responseMoodTagExpressing.
  ///
  /// In en, this message translates to:
  /// **'Expressing'**
  String get responseMoodTagExpressing;

  /// No description provided for @responseMoodTagReflecting.
  ///
  /// In en, this message translates to:
  /// **'Reflecting'**
  String get responseMoodTagReflecting;

  /// No description provided for @responseMoodTagGrowing.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get responseMoodTagGrowing;

  /// No description provided for @responseThinkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Luna is thinking'**
  String get responseThinkingLabel;

  /// No description provided for @responseShareCardHeading.
  ///
  /// In en, this message translates to:
  /// **'Luna says'**
  String get responseShareCardHeading;

  /// No description provided for @responseYourMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR MOOD'**
  String get responseYourMoodLabel;

  /// No description provided for @responseLunaSaysLabel.
  ///
  /// In en, this message translates to:
  /// **'LUNA SAYS'**
  String get responseLunaSaysLabel;

  /// No description provided for @responseSaveQuoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save quote'**
  String get responseSaveQuoteTooltip;

  /// No description provided for @responseCopiedToClipboardSnack.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard 🌿'**
  String get responseCopiedToClipboardSnack;

  /// No description provided for @lunaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your journaling companion'**
  String get lunaSubtitle;

  /// No description provided for @afterFeelingPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling after this?'**
  String get afterFeelingPromptLabel;

  /// No description provided for @afterFeelingCalmLabel.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get afterFeelingCalmLabel;

  /// No description provided for @afterFeelingCalmMessage.
  ///
  /// In en, this message translates to:
  /// **'Thanks for checking in with yourself.'**
  String get afterFeelingCalmMessage;

  /// No description provided for @afterFeelingLovedLabel.
  ///
  /// In en, this message translates to:
  /// **'Loved'**
  String get afterFeelingLovedLabel;

  /// No description provided for @afterFeelingLovedMessage.
  ///
  /// In en, this message translates to:
  /// **'You deserve every bit of that love. Hold onto it.'**
  String get afterFeelingLovedMessage;

  /// No description provided for @afterFeelingBetterLabel.
  ///
  /// In en, this message translates to:
  /// **'Better'**
  String get afterFeelingBetterLabel;

  /// No description provided for @afterFeelingBetterMessage.
  ///
  /// In en, this message translates to:
  /// **'Thanks for taking a moment to reflect.'**
  String get afterFeelingBetterMessage;

  /// No description provided for @afterFeelingStillSadLabel.
  ///
  /// In en, this message translates to:
  /// **'Still sad'**
  String get afterFeelingStillSadLabel;

  /// No description provided for @afterFeelingStillSadMessage.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to still feel this way. Take your time, and reach out to someone you trust if you want support.'**
  String get afterFeelingStillSadMessage;

  /// No description provided for @afterFeelingYouAreFeeling.
  ///
  /// In en, this message translates to:
  /// **'You are feeling {label}'**
  String afterFeelingYouAreFeeling(String label);

  /// No description provided for @afterFeelingTakeYourTime.
  ///
  /// In en, this message translates to:
  /// **'Take your time'**
  String get afterFeelingTakeYourTime;

  /// No description provided for @afterFeelingTalkToLunaAgain.
  ///
  /// In en, this message translates to:
  /// **'Talk to Luna again'**
  String get afterFeelingTalkToLunaAgain;

  /// No description provided for @afterFeelingThankYouLuna.
  ///
  /// In en, this message translates to:
  /// **'Thank you, Luna'**
  String get afterFeelingThankYouLuna;

  /// No description provided for @afterFeelingImOkay.
  ///
  /// In en, this message translates to:
  /// **'I\'ll be okay'**
  String get afterFeelingImOkay;

  /// No description provided for @moodChoicePrompt.
  ///
  /// In en, this message translates to:
  /// **'rough day, huh?'**
  String get moodChoicePrompt;

  /// No description provided for @moodChoiceSubPrompt.
  ///
  /// In en, this message translates to:
  /// **'whatever feels right right now'**
  String get moodChoiceSubPrompt;

  /// No description provided for @moodChoiceTalkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'share what\'s on your mind'**
  String get moodChoiceTalkSubtitle;

  /// No description provided for @moodChoiceBreatheTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathe with Luna'**
  String get moodChoiceBreatheTitle;

  /// No description provided for @moodChoiceBreatheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'a slow, guided breath'**
  String get moodChoiceBreatheSubtitle;

  /// No description provided for @moodChoiceDrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Draw'**
  String get moodChoiceDrawTitle;

  /// No description provided for @moodChoiceDrawSubtitle.
  ///
  /// In en, this message translates to:
  /// **'no pressure, just color'**
  String get moodChoiceDrawSubtitle;

  /// No description provided for @moodChoiceSudokuTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get moodChoiceSudokuTitle;

  /// No description provided for @moodChoiceSudokuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'a small, calm puzzle'**
  String get moodChoiceSudokuSubtitle;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Share what\'s on your mind...'**
  String get chatInputHint;

  /// No description provided for @chatEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Luna 💜\nTell me how you\'re feeling.'**
  String get chatEmptyStateMessage;

  /// No description provided for @chatTypingLabel.
  ///
  /// In en, this message translates to:
  /// **'Luna is typing'**
  String get chatTypingLabel;

  /// No description provided for @chatSessionEndGladMessage.
  ///
  /// In en, this message translates to:
  /// **'I\'m glad you\'re feeling better 💜'**
  String get chatSessionEndGladMessage;

  /// No description provided for @chatSessionEndSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'This session has been saved to your journal.'**
  String get chatSessionEndSavedMessage;

  /// No description provided for @chatBackToHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get chatBackToHomeButton;

  /// No description provided for @sudokuHowToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get sudokuHowToPlayTitle;

  /// No description provided for @sudokuHowToPlayMessage.
  ///
  /// In en, this message translates to:
  /// **'Fill every row, column, and 3x3 box with the digits 1-9, no repeats. Switch to Candidate mode to pencil in notes, and turn on Auto Candidate Mode to have Luna clear out notes for you as you go.'**
  String get sudokuHowToPlayMessage;

  /// No description provided for @sudokuGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get sudokuGotIt;

  /// No description provided for @sudokuNewGameMenuItem.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get sudokuNewGameMenuItem;

  /// No description provided for @sudokuDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get sudokuDifficultyEasy;

  /// No description provided for @sudokuMistakesLabel.
  ///
  /// In en, this message translates to:
  /// **'Mistakes: {mistakes}/{max}'**
  String sudokuMistakesLabel(int mistakes, int max);

  /// No description provided for @sudokuPausedLabel.
  ///
  /// In en, this message translates to:
  /// **'paused'**
  String get sudokuPausedLabel;

  /// No description provided for @sudokuDoneButton.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get sudokuDoneButton;

  /// No description provided for @sudokuOutcomeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You did it! 🌟'**
  String get sudokuOutcomeSuccessMessage;

  /// No description provided for @sudokuOutcomeFailMessage.
  ///
  /// In en, this message translates to:
  /// **'No worries, some puzzles are tricky 🌱'**
  String get sudokuOutcomeFailMessage;

  /// No description provided for @sudokuResultSaveFailedNotice.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save this round to your history — no biggie, keep playing!'**
  String get sudokuResultSaveFailedNotice;

  /// No description provided for @sudokuOutcomeNewGameButton.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get sudokuOutcomeNewGameButton;

  /// No description provided for @sudokuOutcomeBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get sudokuOutcomeBackButton;

  /// No description provided for @sudokuAutoCandidateModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto Candidate Mode'**
  String get sudokuAutoCandidateModeLabel;

  /// No description provided for @sudokuNormalModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get sudokuNormalModeLabel;

  /// No description provided for @sudokuCandidateModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get sudokuCandidateModeLabel;

  /// No description provided for @drawTopBarTitle.
  ///
  /// In en, this message translates to:
  /// **'free draw'**
  String get drawTopBarTitle;

  /// No description provided for @drawUndoButton.
  ///
  /// In en, this message translates to:
  /// **'undo'**
  String get drawUndoButton;

  /// No description provided for @drawClearButton.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get drawClearButton;

  /// No description provided for @drawSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Drawing saved to your profile'**
  String get drawSavedSnack;

  /// No description provided for @drawTalkToLunaLink.
  ///
  /// In en, this message translates to:
  /// **'feel like talking to luna now?'**
  String get drawTalkToLunaLink;

  /// No description provided for @drawViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'your drawing'**
  String get drawViewerTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lueur member'**
  String get profileSubtitle;

  /// No description provided for @profileFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get profileFallbackName;

  /// No description provided for @profileQuotesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Luna will remember your favorite words.'**
  String get profileQuotesEmptySubtitle;

  /// No description provided for @profileStatsTotalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total entries'**
  String get profileStatsTotalEntries;

  /// No description provided for @profileStatsDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get profileStatsDayStreak;

  /// No description provided for @profileStatsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get profileStatsSectionLabel;

  /// No description provided for @profileQuickLinksSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get profileQuickLinksSectionLabel;

  /// No description provided for @profileQuickLinkWeeklyLetter.
  ///
  /// In en, this message translates to:
  /// **'Weekly Letter'**
  String get profileQuickLinkWeeklyLetter;

  /// No description provided for @profileQuickLinkMoodBoard.
  ///
  /// In en, this message translates to:
  /// **'Mood Board'**
  String get profileQuickLinkMoodBoard;

  /// No description provided for @profileSettingsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get profileSettingsSectionLabel;

  /// No description provided for @profileSettingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileSettingsAppearance;

  /// No description provided for @profileSettingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileSettingsLanguage;

  /// No description provided for @profileJournalDataSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'JOURNAL DATA'**
  String get profileJournalDataSectionLabel;

  /// No description provided for @profileDeleteAllEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete all journal entries'**
  String get profileDeleteAllEntriesLabel;

  /// No description provided for @profileDrawingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Drawings'**
  String get profileDrawingsTitle;

  /// No description provided for @profileDrawingsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your drawings — pull to refresh and try again'**
  String get profileDrawingsErrorSubtitle;

  /// No description provided for @profileDrawingsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your creativity has a home here.'**
  String get profileDrawingsEmptySubtitle;

  /// No description provided for @profileSudokuHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku History'**
  String get profileSudokuHistoryTitle;

  /// No description provided for @profileSudokuHistoryErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your Sudoku history — pull to refresh and try again'**
  String get profileSudokuHistoryErrorSubtitle;

  /// No description provided for @profileSudokuHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play a round of Sudoku to see your results here'**
  String get profileSudokuHistoryEmptySubtitle;

  /// No description provided for @profileSudokuRelativeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get profileSudokuRelativeToday;

  /// No description provided for @profileSudokuRelativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get profileSudokuRelativeYesterday;

  /// No description provided for @profileSudokuSolvedIt.
  ///
  /// In en, this message translates to:
  /// **'Solved it'**
  String get profileSudokuSolvedIt;

  /// No description provided for @profileSudokuGaveItAGo.
  ///
  /// In en, this message translates to:
  /// **'Gave it a go'**
  String get profileSudokuGaveItAGo;

  /// No description provided for @profileSudokuRelativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{1 day ago} other{{days} days ago}}'**
  String profileSudokuRelativeDaysAgo(int days);

  /// No description provided for @profileSudokuMistakesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 mistake} other{{count} mistakes}}'**
  String profileSudokuMistakesCount(int count);

  /// No description provided for @breathingHeaderLabel.
  ///
  /// In en, this message translates to:
  /// **'guided breathing'**
  String get breathingHeaderLabel;

  /// No description provided for @breathingPhaseIn.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get breathingPhaseIn;

  /// No description provided for @breathingPhaseOut.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get breathingPhaseOut;

  /// No description provided for @affirmationHeader.
  ///
  /// In en, this message translates to:
  /// **'A word from Luna 💙'**
  String get affirmationHeader;

  /// No description provided for @affirmationSubheader.
  ///
  /// In en, this message translates to:
  /// **'A personalized card just for you'**
  String get affirmationSubheader;

  /// No description provided for @affirmationSignature.
  ///
  /// In en, this message translates to:
  /// **'— Luna 🌿'**
  String get affirmationSignature;

  /// No description provided for @affirmationNextCardButton.
  ///
  /// In en, this message translates to:
  /// **'Next card ↻'**
  String get affirmationNextCardButton;

  /// No description provided for @affirmationPrimaryStartBreathing.
  ///
  /// In en, this message translates to:
  /// **'Start breathing'**
  String get affirmationPrimaryStartBreathing;

  /// No description provided for @affirmationPrimaryStartDrawing.
  ///
  /// In en, this message translates to:
  /// **'Start drawing'**
  String get affirmationPrimaryStartDrawing;

  /// No description provided for @affirmationPrimaryPlaySudoku.
  ///
  /// In en, this message translates to:
  /// **'Play Sudoku'**
  String get affirmationPrimaryPlaySudoku;

  /// No description provided for @lunaCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Feel a little lighter?'**
  String get lunaCheckInTitle;

  /// No description provided for @lunaCheckInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m here if you want to talk more.'**
  String get lunaCheckInSubtitle;

  /// No description provided for @lunaCheckInDismiss.
  ///
  /// In en, this message translates to:
  /// **'I\'m good for now'**
  String get lunaCheckInDismiss;

  /// No description provided for @streakCelebrationKeepGoingButton.
  ///
  /// In en, this message translates to:
  /// **'keep going'**
  String get streakCelebrationKeepGoingButton;

  /// No description provided for @chatSendFailedMessages0.
  ///
  /// In en, this message translates to:
  /// **'hmm that didn\'t send, try again?'**
  String get chatSendFailedMessages0;

  /// No description provided for @chatSendFailedMessages1.
  ///
  /// In en, this message translates to:
  /// **'ugh my signal\'s being weird, say that again?'**
  String get chatSendFailedMessages1;

  /// No description provided for @chatSendFailedMessages2.
  ///
  /// In en, this message translates to:
  /// **'wait that got cut off, one more time?'**
  String get chatSendFailedMessages2;

  /// No description provided for @chatSendFailedMessages3.
  ///
  /// In en, this message translates to:
  /// **'hold on, didn\'t catch that — try sending again'**
  String get chatSendFailedMessages3;

  /// No description provided for @chatSendFailedMessages4.
  ///
  /// In en, this message translates to:
  /// **'hmm something glitched, can you resend that?'**
  String get chatSendFailedMessages4;

  /// No description provided for @streakCelebrationAffirmations0.
  ///
  /// In en, this message translates to:
  /// **'A whole week of showing up for yourself. Luna noticed 🌸'**
  String get streakCelebrationAffirmations0;

  /// No description provided for @streakCelebrationAffirmations1.
  ///
  /// In en, this message translates to:
  /// **'Seven days of choosing yourself, one thought at a time.'**
  String get streakCelebrationAffirmations1;

  /// No description provided for @streakCelebrationAffirmations2.
  ///
  /// In en, this message translates to:
  /// **'You kept coming back — that\'s the whole secret, really.'**
  String get streakCelebrationAffirmations2;

  /// No description provided for @streakCelebrationAffirmations3.
  ///
  /// In en, this message translates to:
  /// **'Luna is so glad you\'re still here, day after day.'**
  String get streakCelebrationAffirmations3;

  /// No description provided for @streakCelebrationAffirmations4.
  ///
  /// In en, this message translates to:
  /// **'This is what taking care of you looks like. Keep it up.'**
  String get streakCelebrationAffirmations4;

  /// No description provided for @streakCelebrationAffirmations5.
  ///
  /// In en, this message translates to:
  /// **'A full week, gently and honestly. That\'s worth celebrating.'**
  String get streakCelebrationAffirmations5;

  /// No description provided for @streakCelebrationNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'{days} days until your next milestone'**
  String streakCelebrationNextMilestone(int days);

  /// No description provided for @streakCelebrationAllMilestonesReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached every milestone — Luna is in awe'**
  String get streakCelebrationAllMilestonesReached;

  /// No description provided for @streakCelebrationEyebrowLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak days'**
  String get streakCelebrationEyebrowLabel;

  /// No description provided for @streakCelebrationProgressSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress toward your next milestone'**
  String get streakCelebrationProgressSemanticLabel;

  /// No description provided for @streakGrowthStageSeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Seed 🌱'**
  String get streakGrowthStageSeedLabel;

  /// No description provided for @streakGrowthStageSproutLabel.
  ///
  /// In en, this message translates to:
  /// **'Sprout 🌿'**
  String get streakGrowthStageSproutLabel;

  /// No description provided for @streakGrowthStagePlantLabel.
  ///
  /// In en, this message translates to:
  /// **'Growing 🪴'**
  String get streakGrowthStagePlantLabel;

  /// No description provided for @streakGrowthStageBlossomLabel.
  ///
  /// In en, this message translates to:
  /// **'Blossom 🌺'**
  String get streakGrowthStageBlossomLabel;

  /// No description provided for @streakGrowthStageBloomingLabel.
  ///
  /// In en, this message translates to:
  /// **'Blooming 🌸'**
  String get streakGrowthStageBloomingLabel;

  /// No description provided for @authSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in!'**
  String get authSuccessTitle;

  /// No description provided for @authSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Luna\'s glad you\'re here.'**
  String get authSuccessMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
