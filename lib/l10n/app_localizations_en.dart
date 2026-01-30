// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Synapse Care';

  @override
  String get brandTagline =>
      'Intelligent platform for care management and patient follow-up.';

  @override
  String get welcomeHeadline => 'Welcome to Synapse Care';

  @override
  String get welcomeBody =>
      'The intelligent platform for care management and patient follow-up.';

  @override
  String get accessSpace => 'Access the application space';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'The requested URL does not exist.';

  @override
  String get backHome => 'Back to home';

  @override
  String get accessDeniedTitle => 'Access denied';

  @override
  String get accessDeniedBody =>
      'You do not have permission to access this page.';

  @override
  String get backHomeCta => 'Back to home';

  @override
  String get login => 'Sign in';

  @override
  String get signup => 'Sign up';

  @override
  String get emailHint => 'Email address';

  @override
  String get nameHint => 'Full name';

  @override
  String get specialtyHint => 'Specialty';

  @override
  String get nameEmptyError => 'Please enter your full name';

  @override
  String get emailEmptyError => 'Please enter your email address';

  @override
  String get emailInvalidError => 'Please enter a valid email address';

  @override
  String get specialtyEmptyError => 'Please enter your specialty';

  @override
  String get passwordEmptyError => 'Please enter your password';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginInvalid => 'Email or password are wrong';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginNetworkError =>
      'Cannot connect to the server. Please check your internet connection.';

  @override
  String get timeoutTitle => 'Session expired';

  @override
  String get timeoutBody =>
      'You will be redirected to the login page in 5 seconds.';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordNeedSpecial => 'Password must include . , + * or ?';

  @override
  String get passwordNeedUpper => 'Password must include one capital letter';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get continueCta => 'Continue';

  @override
  String get quickSms => 'Fast and secure SMS login';

  @override
  String get newHere => 'New to Synapse Care? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get createAccount => 'Create an account';

  @override
  String get signIn => 'Sign in';

  @override
  String get patient => 'Patient';

  @override
  String get doctor => 'Doctor';

  @override
  String get cabinetSearchTitle => 'Find your medical clinic';

  @override
  String get cabinetSearchHint => 'Search your medical clinic';

  @override
  String get cabinetSearchHelper => 'Search by name, city, or specialty.';

  @override
  String get cabinetSearchEmpty => 'No clinics found.';

  @override
  String get cabinetAddSuccess => 'Clinic added successfully.';

  @override
  String get cabinetAddExists => 'Clinic already added.';

  @override
  String get cabinetAddFailed => 'Could not add clinic.';

  @override
  String get cabinetSelectTitle => 'Choose your clinic';

  @override
  String get cabinetSelectBody =>
      'Select the medical clinic you are affiliated with.';

  @override
  String get cabinetSelectSampleSpecialty => 'General medicine';

  @override
  String get cabinetSelectEmpty => 'No affiliated clinics found.';

  @override
  String get cabinetSelectUnnamed => 'Unnamed clinic';

  @override
  String get cabinetSelectAdd => 'Add a clinic';

  @override
  String get cabinetSelectFind => 'Find a clinic';

  @override
  String get homeSearchHint => 'Rechercher...';

  @override
  String get homeDashboardTitle => 'Dashboard';

  @override
  String get homeDashAppointments => 'Appointments';

  @override
  String get homeDashConsultationsToday => 'Consultations today';

  @override
  String get homeDashPatients => 'Patients';

  @override
  String get homeDashRevenue => 'Revenue';

  @override
  String get homeDashAlerts => 'Alerts';

  @override
  String get homeDashConsultationsMonth => 'Consultations this month';

  @override
  String get homeDashNextTitle => 'Next appointment';

  @override
  String get homeDashNextSubtitle => '09:30 • Amina B. • Consultation';

  @override
  String get homeMenuConsultation => 'Consultation';

  @override
  String get homeMenuHistory => 'History';

  @override
  String get homeMenuCaisse => 'Caisse';

  @override
  String get homeMenuSettings => 'Settings';

  @override
  String get homeMenuData => 'Data';

  @override
  String get homeMenuAbout => 'About';

  @override
  String get homeMenuToday => 'Today';

  @override
  String get homeMenuRdvTake => 'Take appointment';

  @override
  String get homeMenuRdvList => 'Appointments list';

  @override
  String get homeMenuProfile => 'My profile';

  @override
  String get homeMenuChangeClinic => 'Change clinic';

  @override
  String get homeMenuLogout => 'Log out';

  @override
  String homeGreeting(Object name) {
    return 'Dr. $name';
  }

  @override
  String get phoneHint => 'Phone number';

  @override
  String get phoneEmptyError => 'Please enter a phone number';

  @override
  String get phoneInvalidPrefixError => 'Number must start with 5, 6, or 7';

  @override
  String otpSend(Object phone) {
    return 'Sending OTP code to $phone';
  }

  @override
  String otpValidDemo(Object phone) {
    return 'This $phone is valid for the demo.';
  }
}
