import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ckb.dart';
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
    Locale('ckb'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Manager'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(String error);

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update: {error}'**
  String failedToUpdate(String error);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @permission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permission;

  /// No description provided for @activitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTitle;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @createActivityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Activity Card'**
  String get createActivityCardTitle;

  /// No description provided for @updateActivityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Activity Card'**
  String get updateActivityCardTitle;

  /// No description provided for @deleteActivityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Activity Card'**
  String get deleteActivityCardTitle;

  /// No description provided for @deleteActivityCardContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card and all its records?'**
  String get deleteActivityCardContent;

  /// No description provided for @cardTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Title'**
  String get cardTitleLabel;

  /// No description provided for @activityCardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Activity Card and its records deleted'**
  String get activityCardDeleted;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @gradesSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Grades saved successfully!'**
  String get gradesSavedSuccessfully;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(String error);

  /// No description provided for @saveAllGrades.
  ///
  /// In en, this message translates to:
  /// **'Save All Grades'**
  String get saveAllGrades;

  /// No description provided for @addStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudentTitle;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @studentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Student Added Successfully'**
  String get studentAddedSuccessfully;

  /// No description provided for @studentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Student Name'**
  String get studentNameLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @educationLabel.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationLabel;

  /// No description provided for @maritalStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatusLabel;

  /// No description provided for @saveStudent.
  ///
  /// In en, this message translates to:
  /// **'Save Student'**
  String get saveStudent;

  /// No description provided for @educationTwelfthGrade.
  ///
  /// In en, this message translates to:
  /// **'Twelfth grade'**
  String get educationTwelfthGrade;

  /// No description provided for @educationDiploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma\'s Degree'**
  String get educationDiploma;

  /// No description provided for @educationBachelor.
  ///
  /// In en, this message translates to:
  /// **'Bachelor\'s Degree'**
  String get educationBachelor;

  /// No description provided for @maritalMarried.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get maritalMarried;

  /// No description provided for @maritalSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get maritalSingle;

  /// No description provided for @attendanceYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance - {year}'**
  String attendanceYearTitle(String year);

  /// No description provided for @fridaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Fridays'**
  String fridaysCount(int count);

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @noStudentsFound.
  ///
  /// In en, this message translates to:
  /// **'No students found.'**
  String get noStudentsFound;

  /// No description provided for @noFridaysInMonth.
  ///
  /// In en, this message translates to:
  /// **'No Fridays in this month.'**
  String get noFridaysInMonth;

  /// No description provided for @attendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved.'**
  String get attendanceSaved;

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance'**
  String get saveAttendance;

  /// No description provided for @fridayDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Friday {date}'**
  String fridayDateLabel(String date);

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @informationDrawerHeader.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationDrawerHeader;

  /// No description provided for @addStudentDrawer.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudentDrawer;

  /// No description provided for @searchStudentDrawer.
  ///
  /// In en, this message translates to:
  /// **'Search Student'**
  String get searchStudentDrawer;

  /// No description provided for @totalStudentsDrawer.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudentsDrawer;

  /// No description provided for @attendanceDrawer.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceDrawer;

  /// No description provided for @paymentsDrawer.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsDrawer;

  /// No description provided for @activitiesDrawer.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesDrawer;

  /// No description provided for @changePasswordDrawer.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordDrawer;

  /// No description provided for @logoutDrawer.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutDrawer;

  /// No description provided for @noStudentsFoundBig.
  ///
  /// In en, this message translates to:
  /// **'No Students Found'**
  String get noStudentsFoundBig;

  /// No description provided for @deleteStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Student'**
  String get deleteStudentTitle;

  /// No description provided for @deleteStudentDashboardContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this student and all their activity/attendance data?'**
  String get deleteStudentDashboardContent;

  /// No description provided for @studentAndRecordsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Student and all related records deleted'**
  String get studentAndRecordsDeleted;

  /// No description provided for @phoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone: {value}'**
  String phoneField(String value);

  /// No description provided for @locationField.
  ///
  /// In en, this message translates to:
  /// **'Location: {value}'**
  String locationField(String value);

  /// No description provided for @ageField.
  ///
  /// In en, this message translates to:
  /// **'Age: {value}'**
  String ageField(String value);

  /// No description provided for @educationField.
  ///
  /// In en, this message translates to:
  /// **'Education: {value}'**
  String educationField(String value);

  /// No description provided for @statusField.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String statusField(String value);

  /// No description provided for @editStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Student'**
  String get editStudentTitle;

  /// No description provided for @studentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Student Updated'**
  String get studentUpdated;

  /// No description provided for @deleteStudentEditContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this student? This also removes all of their associated records.'**
  String get deleteStudentEditContent;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Permission denied: Ensure you are logged in with an admin account.'**
  String get permissionDeniedMessage;

  /// No description provided for @studentDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Student Deleted Successfully'**
  String get studentDeletedSuccessfully;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @deleteStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Student'**
  String get deleteStudentButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignUp;

  /// No description provided for @addStudentsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Students'**
  String get addStudentsSheetTitle;

  /// No description provided for @allStudentsAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'All students have already been added.'**
  String get allStudentsAlreadyAdded;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected ({count})'**
  String addSelected(int count);

  /// No description provided for @removeStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Student'**
  String get removeStudentTitle;

  /// No description provided for @removeStudentContent.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {period}? This deletes their saved payment for this period too.'**
  String removeStudentContent(String name, String period);

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @unpaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaidLabel;

  /// No description provided for @paymentsSaved.
  ///
  /// In en, this message translates to:
  /// **'Payments saved.'**
  String get paymentsSaved;

  /// No description provided for @noStudentsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No students added yet.'**
  String get noStudentsAddedYet;

  /// No description provided for @addStudentsButton.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get addStudentsButton;

  /// No description provided for @savePayments.
  ///
  /// In en, this message translates to:
  /// **'Save Payments'**
  String get savePayments;

  /// No description provided for @weeklyPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Payments - {year}'**
  String weeklyPaymentsTitle(String year);

  /// No description provided for @monthlyPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payments - {year}'**
  String monthlyPaymentsTitle(String year);

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {n}'**
  String weekLabel(int n);

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// No description provided for @weeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyTitle;

  /// No description provided for @weeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charge students by the week'**
  String get weeklySubtitle;

  /// No description provided for @monthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyTitle;

  /// No description provided for @monthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charge students by the month'**
  String get monthlySubtitle;

  /// No description provided for @searchStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Student'**
  String get searchStudentTitle;

  /// No description provided for @searchByNameHint.
  ///
  /// In en, this message translates to:
  /// **'Search by student name'**
  String get searchByNameHint;

  /// No description provided for @noStudentFound.
  ///
  /// In en, this message translates to:
  /// **'No Student Found'**
  String get noStudentFound;

  /// No description provided for @maritalStatusField.
  ///
  /// In en, this message translates to:
  /// **'Marital Status: {value}'**
  String maritalStatusField(String value);

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccessfully;

  /// No description provided for @registerAsLabel.
  ///
  /// In en, this message translates to:
  /// **'Register As'**
  String get registerAsLabel;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userRole;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @totalStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudentsTitle;

  /// No description provided for @totalNumberOfStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Number of Students'**
  String get totalNumberOfStudents;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageMenuTooltip;
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
      <String>['ckb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
