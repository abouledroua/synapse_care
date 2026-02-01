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
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get patientListTitle => 'List of Patients';

  @override
  String get patientListAddNew => 'Add New Patient';

  @override
  String get patientListRefresh => 'Refresh';

  @override
  String get patientListAddComingSoon => 'Coming soon';

  @override
  String get patientHeaderFullName => 'Full Name';

  @override
  String get patientHeaderSexe => 'Sex';

  @override
  String get patientHeaderAge => 'Age';

  @override
  String get patientHeaderPhone => 'Phone';

  @override
  String get patientHeaderAddress => 'Address';

  @override
  String get patientHeaderDebt => 'Debt';

  @override
  String get patientHeaderBloodGroup => 'Blood group';

  @override
  String get patientHeaderActions => 'Actions';

  @override
  String get patientHeaderNin => 'NIN';

  @override
  String get patientHeaderNss => 'NSS';

  @override
  String get patientHeaderEmail => 'Email';

  @override
  String get patientSexMale => 'Male';

  @override
  String get patientSexFemale => 'Female';

  @override
  String get patientActionUpdate => 'Update';

  @override
  String get patientActionDelete => 'Delete';

  @override
  String get patientAgeYears => 'year(s)';

  @override
  String get patientAgeMonths => 'month(s)';

  @override
  String get patientAgeDays => 'day(s)';

  @override
  String get patientCurrencyDzdLatin => 'DA';

  @override
  String get patientCurrencyDzdArabic => 'دج';

  @override
  String get patientCreateTitle => 'Create Patient';

  @override
  String get patientCreateSubmit => 'Save';

  @override
  String get patientCreateSaving => 'Saving...';

  @override
  String get patientCreateSuccess => 'Patient created.';

  @override
  String get patientCreateFailed => 'Could not create patient.';

  @override
  String get patientSectionIdentity => 'Identity';

  @override
  String get patientSectionContact => 'Contact';

  @override
  String get patientSectionInsurance => 'Insurance';

  @override
  String get patientFieldCodeBarre => 'Barcode';

  @override
  String get patientFieldNom => 'Last name';

  @override
  String get patientFieldPrenom => 'First name';

  @override
  String get patientFieldDateNaissance => 'Date of birth';

  @override
  String get patientFieldEmail => 'Email';

  @override
  String get patientFieldAge => 'Age';

  @override
  String get patientFieldTel1 => 'Phone 1';

  @override
  String get patientFieldTel2 => 'Phone 2';

  @override
  String get patientFieldWilaya => 'Wilaya';

  @override
  String get patientFieldApc => 'APC';

  @override
  String get patientFieldAdresse => 'Address';

  @override
  String get patientFieldDette => 'Debt';

  @override
  String get patientFieldPresume => 'Presumed';

  @override
  String get patientFieldSexe => 'Sex';

  @override
  String get patientFieldTypeAge => 'Age unit';

  @override
  String get patientFieldConventionne => 'Insured';

  @override
  String get patientFieldPourcConv => 'Coverage (%)';

  @override
  String get patientFieldLieuNaissance => 'Place of birth';

  @override
  String get patientFieldGs => 'Blood group';

  @override
  String get patientFieldProfession => 'Profession';

  @override
  String get patientFieldDiagnostique => 'Diagnosis';

  @override
  String get patientFieldNin => 'NIN';

  @override
  String get patientFieldNss => 'NSS';

  @override
  String get patientFieldNbImpression => 'Print count';

  @override
  String get patientFieldCodeMalade => 'Patient code';

  @override
  String get patientFieldPhotoUrl => 'Photo URL';

  @override
  String get patientOptionYes => 'Yes';

  @override
  String get patientOptionNo => 'No';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get fieldInvalidNumber => 'Invalid number';

  @override
  String get patientListUpdateComingSoon => 'Update coming soon';

  @override
  String get patientListDeleteComingSoon => 'Delete coming soon';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'The requested URL does not exist.';

  @override
  String get notFoundCode => '404';

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
  String get cabinetSearchAddNew => 'Add New Clinic';

  @override
  String get cabinetSearchAddNewComingSoon => 'Coming soon';

  @override
  String get cabinetCreateTitle => 'Create a new clinic';

  @override
  String get cabinetCreateSubmit => 'Create clinic';

  @override
  String get cabinetNameHint => 'Clinic name';

  @override
  String get cabinetNameEmptyError => 'Please enter the clinic name';

  @override
  String get cabinetAddressHint => 'Clinic address';

  @override
  String get cabinetAddressEmptyError => 'Please enter the clinic address';

  @override
  String get cabinetAddSuccess => 'Clinic added successfully.';

  @override
  String get cabinetAddExists => 'Clinic already added.';

  @override
  String get cabinetAddFailed => 'could not add clinic';

  @override
  String get cabinetRemoveAction => 'Remove';

  @override
  String get cabinetRemoveConfirmTitle => 'Remove clinic?';

  @override
  String get cabinetRemoveConfirmBody =>
      'This will remove your affiliation with this clinic.';

  @override
  String get cabinetRemoveConfirm => 'Remove';

  @override
  String get cabinetRemoveCancel => 'Cancel';

  @override
  String get cabinetRemoveSuccess => 'Clinic removed.';

  @override
  String get cabinetRemoveFailed => 'Could not remove clinic.';

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
  String get homePatientSearchEmpty => 'No patients found.';

  @override
  String get homePatientSearchUnnamed => 'Unnamed patient';

  @override
  String get homeMenuConsultation => 'Consultation';

  @override
  String get homeMenuPatientsList => 'Patients';

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
  String get homeMenuRdvList => 'Appointments';

  @override
  String get homeMenuProfile => 'My profile';

  @override
  String get homeMenuChangeClinic => 'Change clinic';

  @override
  String get homeMenuLogout => 'Log out';

  @override
  String get homeMenuOpenTooltip => 'Open menu';

  @override
  String get homeLogoutConfirmMessage => 'Are you sure you want to log out?';

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
