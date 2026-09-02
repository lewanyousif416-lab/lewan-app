// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Student Manager';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String failedToUpdate(String error) {
    return 'Failed to update: $error';
  }

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get permission => 'Permission';

  @override
  String get presentStudentsTitle => 'Present Students';

  @override
  String get absentStudentsTitle => 'Absent Students';

  @override
  String get permissionStudentsTitle => 'Students with Permission';

  @override
  String get noStudentsWithStatus => 'No students in this list yet.';

  @override
  String get activitiesTitle => 'Activities';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String get createActivityCardTitle => 'Create Activity Card';

  @override
  String get updateActivityCardTitle => 'Update Activity Card';

  @override
  String get deleteActivityCardTitle => 'Delete Activity Card';

  @override
  String get deleteActivityCardContent =>
      'Are you sure you want to delete this card and all its records?';

  @override
  String get cardTitleLabel => 'Card Title';

  @override
  String get activityCardDeleted => 'Activity Card and its records deleted';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get gradesSavedSuccessfully => 'Grades saved successfully!';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get saveAllGrades => 'Save All Grades';

  @override
  String get addStudentTitle => 'Add Student';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get studentAddedSuccessfully => 'Student Added Successfully';

  @override
  String get studentNameLabel => 'Student Name';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get locationLabel => 'Location';

  @override
  String get ageLabel => 'Age';

  @override
  String get educationLabel => 'Education';

  @override
  String get maritalStatusLabel => 'Marital Status';

  @override
  String get saveStudent => 'Save Student';

  @override
  String get educationTwelfthGrade => 'Twelfth grade';

  @override
  String get educationDiploma => 'Diploma\'s Degree';

  @override
  String get educationBachelor => 'Bachelor\'s Degree';

  @override
  String get maritalMarried => 'Married';

  @override
  String get maritalSingle => 'Single';

  @override
  String attendanceYearTitle(String year) {
    return 'Attendance - $year';
  }

  @override
  String fridaysCount(int count) {
    return '$count Fridays';
  }

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get noStudentsFound => 'No students found.';

  @override
  String get noFridaysInMonth => 'No Fridays in this month.';

  @override
  String get attendanceSaved => 'Attendance saved.';

  @override
  String get saveAttendance => 'Save Attendance';

  @override
  String fridayDateLabel(String date) {
    return 'Friday $date';
  }

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get failedToChangePassword => 'Failed to change password';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get informationDrawerHeader => 'Information';

  @override
  String get addStudentDrawer => 'Add Student';

  @override
  String get searchStudentDrawer => 'Search Student';

  @override
  String get totalStudentsDrawer => 'Total Students';

  @override
  String get attendanceDrawer => 'Attendance';

  @override
  String get paymentsDrawer => 'Payments';

  @override
  String get activitiesDrawer => 'Activities';

  @override
  String get changePasswordDrawer => 'Change Password';

  @override
  String get logoutDrawer => 'Logout';

  @override
  String get noStudentsFoundBig => 'No Students Found';

  @override
  String get deleteStudentTitle => 'Delete Student';

  @override
  String get deleteStudentDashboardContent =>
      'Are you sure you want to delete this student and all their activity/attendance data?';

  @override
  String get studentAndRecordsDeleted =>
      'Student and all related records deleted';

  @override
  String phoneField(String value) {
    return 'Phone: $value';
  }

  @override
  String locationField(String value) {
    return 'Location: $value';
  }

  @override
  String ageField(String value) {
    return 'Age: $value';
  }

  @override
  String educationField(String value) {
    return 'Education: $value';
  }

  @override
  String statusField(String value) {
    return 'Status: $value';
  }

  @override
  String get editStudentTitle => 'Edit Student';

  @override
  String get studentUpdated => 'Student Updated';

  @override
  String get deleteStudentEditContent =>
      'Are you sure you want to delete this student? This also removes all of their associated records.';

  @override
  String get permissionDeniedMessage =>
      'Permission denied: Ensure you are logged in with an admin account.';

  @override
  String get studentDeletedSuccessfully => 'Student Deleted Successfully';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get deleteStudentButton => 'Delete Student';

  @override
  String get loginTitle => 'Login';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get addStudentsSheetTitle => 'Add Students';

  @override
  String get allStudentsAlreadyAdded => 'All students have already been added.';

  @override
  String addSelected(int count) {
    return 'Add Selected ($count)';
  }

  @override
  String get removeStudentTitle => 'Remove Student';

  @override
  String removeStudentContent(String name, String period) {
    return 'Remove $name from $period? This deletes their saved payment for this period too.';
  }

  @override
  String get priceLabel => 'Price';

  @override
  String get paidLabel => 'Paid';

  @override
  String get unpaidLabel => 'Unpaid';

  @override
  String get paymentsSaved => 'Payments saved.';

  @override
  String get noStudentsAddedYet => 'No students added yet.';

  @override
  String get addStudentsButton => 'Add students';

  @override
  String get savePayments => 'Save Payments';

  @override
  String weeklyPaymentsTitle(String year) {
    return 'Weekly Payments - $year';
  }

  @override
  String monthlyPaymentsTitle(String year) {
    return 'Monthly Payments - $year';
  }

  @override
  String weekLabel(int n) {
    return 'Week $n';
  }

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get weeklyTitle => 'Weekly';

  @override
  String get weeklySubtitle => 'Charge students by the week';

  @override
  String get monthlyTitle => 'Monthly';

  @override
  String get monthlySubtitle => 'Charge students by the month';

  @override
  String get searchStudentTitle => 'Search Student';

  @override
  String get searchByNameHint => 'Search by student name';

  @override
  String get noStudentFound => 'No Student Found';

  @override
  String maritalStatusField(String value) {
    return 'Marital Status: $value';
  }

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully';

  @override
  String get registerAsLabel => 'Register As';

  @override
  String get userRole => 'User';

  @override
  String get adminRole => 'Admin';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get alreadyHaveAccountLogin => 'Already have an account? Login';

  @override
  String get totalStudentsTitle => 'Total Students';

  @override
  String get totalNumberOfStudents => 'Total Number of Students';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get attendanceAnalyticsTitle => 'Attendance Analytics';
}
