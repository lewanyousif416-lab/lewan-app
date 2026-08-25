// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Central Kurdish (`ckb`).
class AppLocalizationsCkb extends AppLocalizations {
  AppLocalizationsCkb([String locale = 'ckb']) : super(locale);

  @override
  String get appTitle => 'بەڕێوەبردنی خوێندکاران';

  @override
  String get cancel => 'پاشگەزبوونەوە';

  @override
  String get delete => 'سڕینەوە';

  @override
  String get update => 'نوێکردنەوە';

  @override
  String get create => 'دروستکردن';

  @override
  String get save => 'پاشەکەوتکردن';

  @override
  String get saving => 'پاشەکەوت دەکرێت...';

  @override
  String error(String error) {
    return 'هەڵە: $error';
  }

  @override
  String get somethingWentWrong => 'هەڵەیەک ڕوویدا';

  @override
  String failedToDelete(String error) {
    return 'سڕینەوە سەرکەوتوو نەبوو: $error';
  }

  @override
  String failedToSave(String error) {
    return 'پاشەکەوتکردن سەرکەوتوو نەبوو: $error';
  }

  @override
  String failedToUpdate(String error) {
    return 'نوێکردنەوە سەرکەوتوو نەبوو: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'هەڵە: $error';
  }

  @override
  String get yes => 'بەڵێ';

  @override
  String get no => 'نەخێر';

  @override
  String get present => 'ئامادە';

  @override
  String get absent => 'ئامادە نەبوو';

  @override
  String get permission => 'مۆڵەت';

  @override
  String get activitiesTitle => 'چالاکییەکان';

  @override
  String get addNewCard => 'کارتی نوێ زیادبکە';

  @override
  String get createActivityCardTitle => 'دروستکردنی کارتی چالاکی';

  @override
  String get updateActivityCardTitle => 'نوێکردنەوەی کارتی چالاکی';

  @override
  String get deleteActivityCardTitle => 'سڕینەوەی کارتی چالاکی';

  @override
  String get deleteActivityCardContent =>
      'دڵنیایت لە سڕینەوەی ئەم کارتە و هەموو تۆمارەکانی؟';

  @override
  String get cardTitleLabel => 'ناونیشانی کارت';

  @override
  String get activityCardDeleted => 'کارتی چالاکی و تۆمارەکانی سڕایەوە';

  @override
  String errorLoadingData(String error) {
    return 'هەڵە لە بارکردنی داتا: $error';
  }

  @override
  String get gradesSavedSuccessfully => 'نمرەکان بە سەرکەوتوویی پاشەکەوت کران!';

  @override
  String errorSaving(String error) {
    return 'هەڵە لە پاشەکەوتکردن: $error';
  }

  @override
  String get saveAllGrades => 'پاشەکەوتکردنی هەموو نمرەکان';

  @override
  String get addStudentTitle => 'زیادکردنی خوێندکار';

  @override
  String get pleaseFillAllFields => 'تکایە هەموو خانەکان پڕبکەوە';

  @override
  String get studentAddedSuccessfully => 'خوێندکار بە سەرکەوتوویی زیادکرا';

  @override
  String get studentNameLabel => 'ناوی خوێندکار';

  @override
  String get phoneNumberLabel => 'ژمارەی مۆبایل';

  @override
  String get locationLabel => 'شوێن';

  @override
  String get ageLabel => 'تەمەن';

  @override
  String get educationLabel => 'خوێندن';

  @override
  String get maritalStatusLabel => 'باری خێزانی';

  @override
  String get saveStudent => 'پاشەکەوتکردنی خوێندکار';

  @override
  String get educationTwelfthGrade => 'پۆلی دوازدە';

  @override
  String get educationDiploma => 'بروانامەی دیپلۆم';

  @override
  String get educationBachelor => 'بروانامەی بەکالۆریۆس';

  @override
  String get maritalMarried => 'هاوسەردار';

  @override
  String get maritalSingle => 'سەڵت';

  @override
  String attendanceYearTitle(String year) {
    return 'ئامادەبوون - $year';
  }

  @override
  String fridaysCount(int count) {
    return '$count هەینی';
  }

  @override
  String get monthJanuary => 'کانوونی دووەم';

  @override
  String get monthFebruary => 'شوبات';

  @override
  String get monthMarch => 'ئازار';

  @override
  String get monthApril => 'نیسان';

  @override
  String get monthMay => 'ئایار';

  @override
  String get monthJune => 'حوزەیران';

  @override
  String get monthJuly => 'تەمووز';

  @override
  String get monthAugust => 'ئاب';

  @override
  String get monthSeptember => 'ئەیلوول';

  @override
  String get monthOctober => 'تشرینی یەکەم';

  @override
  String get monthNovember => 'تشرینی دووەم';

  @override
  String get monthDecember => 'کانوونی یەکەم';

  @override
  String get noStudentsFound => 'هیچ خوێندکارێک نەدۆزرایەوە.';

  @override
  String get noFridaysInMonth => 'هیچ هەینییەک لەم مانگەدا نییە.';

  @override
  String get attendanceSaved => 'ئامادەبوون پاشەکەوت کرا.';

  @override
  String get saveAttendance => 'پاشەکەوتکردنی ئامادەبوون';

  @override
  String fridayDateLabel(String date) {
    return 'هەینی $date';
  }

  @override
  String get changePasswordTitle => 'گۆڕینی وشەی نهێنی';

  @override
  String get currentPasswordLabel => 'وشەی نهێنی ئێستا';

  @override
  String get newPasswordLabel => 'وشەی نهێنی نوێ';

  @override
  String get confirmNewPasswordLabel => 'دووپاتکردنەوەی وشەی نهێنی نوێ';

  @override
  String get newPasswordsDoNotMatch => 'وشە نهێنییە نوێیەکان یەک ناگرنەوە';

  @override
  String get passwordTooShort => 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت';

  @override
  String get passwordChangedSuccessfully => 'وشەی نهێنی بە سەرکەوتوویی گۆڕدرا';

  @override
  String get failedToChangePassword => 'گۆڕینی وشەی نهێنی سەرکەوتوو نەبوو';

  @override
  String get userNotLoggedIn => 'بەکارهێنەر چوونەژوورەوەی نەکردووە';

  @override
  String get changePasswordButton => 'گۆڕینی وشەی نهێنی';

  @override
  String get dashboardTitle => 'داشبۆرد';

  @override
  String get informationDrawerHeader => 'زانیاری';

  @override
  String get addStudentDrawer => 'زیادکردنی خوێندکار';

  @override
  String get searchStudentDrawer => 'گەڕان بۆ خوێندکار';

  @override
  String get totalStudentsDrawer => 'کۆی خوێندکاران';

  @override
  String get attendanceDrawer => 'ئامادەبوون';

  @override
  String get paymentsDrawer => 'پارەدان';

  @override
  String get activitiesDrawer => 'چالاکییەکان';

  @override
  String get changePasswordDrawer => 'گۆڕینی وشەی نهێنی';

  @override
  String get logoutDrawer => 'چوونەدەرەوە';

  @override
  String get noStudentsFoundBig => 'هیچ خوێندکارێک نییە';

  @override
  String get deleteStudentTitle => 'سڕینەوەی خوێندکار';

  @override
  String get deleteStudentDashboardContent =>
      'دڵنیایت لە سڕینەوەی ئەم خوێندکارە و هەموو داتای چالاکی/ئامادەبوونی؟';

  @override
  String get studentAndRecordsDeleted =>
      'خوێندکار و هەموو تۆمارە پەیوەندیدارەکانی سڕایەوە';

  @override
  String phoneField(String value) {
    return 'مۆبایل: $value';
  }

  @override
  String locationField(String value) {
    return 'شوێن: $value';
  }

  @override
  String ageField(String value) {
    return 'تەمەن: $value';
  }

  @override
  String educationField(String value) {
    return 'خوێندن: $value';
  }

  @override
  String statusField(String value) {
    return 'باری خێزانی: $value';
  }

  @override
  String get editStudentTitle => 'دەستکاریکردنی خوێندکار';

  @override
  String get studentUpdated => 'خوێندکار نوێکرایەوە';

  @override
  String get deleteStudentEditContent =>
      'دڵنیایت لە سڕینەوەی ئەم خوێندکارە؟ ئەمە هەموو تۆمارە پەیوەندیدارەکانیشی دەسڕێتەوە.';

  @override
  String get permissionDeniedMessage =>
      'مۆڵەت نەدرا: دڵنیابەرەوە بە هەژماری ئەدمین چوویتەتە ژوورەوە.';

  @override
  String get studentDeletedSuccessfully => 'خوێندکار بە سەرکەوتوویی سڕایەوە';

  @override
  String get nameLabel => 'ناو';

  @override
  String get phoneLabel => 'مۆبایل';

  @override
  String get deleteStudentButton => 'سڕینەوەی خوێندکار';

  @override
  String get loginTitle => 'چوونەژوورەوە';

  @override
  String get signInToContinue => 'بچۆ ژوورەوە بۆ بەردەوامبوون';

  @override
  String get emailLabel => 'ئیمەیل';

  @override
  String get passwordLabel => 'وشەی نهێنی';

  @override
  String get loginButton => 'چوونەژوورەوە';

  @override
  String get noAccountSignUp => 'هەژمارت نییە؟ خۆتۆمارکردن';

  @override
  String get addStudentsSheetTitle => 'زیادکردنی خوێندکاران';

  @override
  String get allStudentsAlreadyAdded => 'هەموو خوێندکاران پێشتر زیادکراون.';

  @override
  String addSelected(int count) {
    return 'زیادکردنی هەڵبژێردراوەکان ($count)';
  }

  @override
  String get removeStudentTitle => 'لابردنی خوێندکار';

  @override
  String removeStudentContent(String name, String period) {
    return '$name لە $period لاببە؟ ئەمە پارەدانی پاشەکەوتکراوی ئەم ماوەیەش دەسڕێتەوە.';
  }

  @override
  String get priceLabel => 'نرخ';

  @override
  String get paidLabel => 'دراوە';

  @override
  String get unpaidLabel => 'نەدراوە';

  @override
  String get paymentsSaved => 'پارەدانەکان پاشەکەوت کران.';

  @override
  String get noStudentsAddedYet => 'هێشتا خوێندکار زیاد نەکراوە.';

  @override
  String get addStudentsButton => 'زیادکردنی خوێندکاران';

  @override
  String get savePayments => 'پاشەکەوتکردنی پارەدانەکان';

  @override
  String weeklyPaymentsTitle(String year) {
    return 'پارەدانی هەفتانە - $year';
  }

  @override
  String monthlyPaymentsTitle(String year) {
    return 'پارەدانی مانگانە - $year';
  }

  @override
  String weekLabel(int n) {
    return 'هەفتەی $n';
  }

  @override
  String get paymentsTitle => 'پارەدانەکان';

  @override
  String get weeklyTitle => 'هەفتانە';

  @override
  String get weeklySubtitle => 'چارجکردنی خوێندکاران بە هەفتانە';

  @override
  String get monthlyTitle => 'مانگانە';

  @override
  String get monthlySubtitle => 'چارجکردنی خوێندکاران بە مانگانە';

  @override
  String get searchStudentTitle => 'گەڕان بۆ خوێندکار';

  @override
  String get searchByNameHint => 'بگەڕێ بە ناوی خوێندکار';

  @override
  String get noStudentFound => 'هیچ خوێندکارێک نەدۆزرایەوە';

  @override
  String maritalStatusField(String value) {
    return 'باری خێزانی: $value';
  }

  @override
  String get createAccountTitle => 'دروستکردنی هەژمار';

  @override
  String get fullNameLabel => 'ناوی تەواو';

  @override
  String get accountCreatedSuccessfully => 'هەژمار بە سەرکەوتوویی دروستکرا';

  @override
  String get registerAsLabel => 'تۆمارکردن وەک';

  @override
  String get userRole => 'بەکارهێنەر';

  @override
  String get adminRole => 'ئەدمین';

  @override
  String get signUpButton => 'خۆتۆمارکردن';

  @override
  String get alreadyHaveAccountLogin => 'هەژمارت هەیە؟ چوونەژوورەوە';

  @override
  String get totalStudentsTitle => 'کۆی خوێندکاران';

  @override
  String get totalNumberOfStudents => 'کۆی ژمارەی خوێندکاران';

  @override
  String get languageMenuTooltip => 'زمان';
}
