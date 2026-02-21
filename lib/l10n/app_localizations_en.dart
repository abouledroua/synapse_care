// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Curatio';

  @override
  String get brandTagline =>
      'Intelligent platform for care management and patient follow-up.';

  @override
  String get welcomeHeadline => 'Welcome to Curatio';

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
  String get appointmentListTitle => 'List of Appointments';

  @override
  String get appointmentListAddNew => 'Add New Appointment';

  @override
  String get appointmentListRefresh => 'Refresh';

  @override
  String get appointmentListEmpty => 'No appointments found.';

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
  String get patientEditTitle => 'Edit Patient';

  @override
  String get patientEditSuccess => 'Patient updated';

  @override
  String get patientEditFailed => 'Failed to update patient';

  @override
  String get patientDeleteConfirmTitle => 'Delete patient';

  @override
  String get patientDeleteConfirmBody =>
      'Are you sure you want to delete this patient?';

  @override
  String get patientDeleteCancel => 'Cancel';

  @override
  String get patientDeleteConfirm => 'Delete';

  @override
  String get patientDeleteSuccess => 'Patient deleted';

  @override
  String get patientDeleteFailed => 'Failed to delete patient';

  @override
  String get patientCreateSubmit => 'Save';

  @override
  String get patientCreateSaving => 'Saving...';

  @override
  String get patientCreateSuccess => 'Patient created.';

  @override
  String get patientCreateLinked =>
      'Patient already exists. Linked to this clinic.';

  @override
  String get patientLinkTitle => 'Patient exists';

  @override
  String get patientLinkBody =>
      'This patient already exists. Do you want to link them to this clinic?';

  @override
  String get patientLinkConfirm => 'Link patient';

  @override
  String get patientLinkCancel => 'Cancel';

  @override
  String get patientLinkSuccess => 'Patient linked to this clinic.';

  @override
  String get patientLinkFailed => 'Could not link patient.';

  @override
  String get patientIdentityExistsInClinic =>
      'This identification number already exists in this clinic.';

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
  String get patientFieldNationality => 'Nationality';

  @override
  String get patientNationalityAlgeria => 'Algeria';

  @override
  String get patientNationalityFrance => 'France';

  @override
  String get patientNationalityOther => 'Other';

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
  String get patientClinicRequired => 'Please select a clinic first.';

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
  String get signupFailed => 'Sign up failed.';

  @override
  String get signupEmailExists => 'Email already exists.';

  @override
  String get signupPhoneExists => 'Phone number already exists.';

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
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a reset link.';

  @override
  String get forgotPasswordEmailHint => 'Email';

  @override
  String get forgotPasswordSend => 'Send reset link';

  @override
  String get forgotPasswordSending => 'Sending...';

  @override
  String get forgotPasswordSuccess =>
      'If the email exists, a reset link was sent.';

  @override
  String get forgotPasswordCodeSent => 'Code sent. Check your email.';

  @override
  String get forgotPasswordEmailNotFound => 'Email does not exist.';

  @override
  String get forgotPasswordCodeHint => 'Verification code';

  @override
  String get forgotPasswordVerify => 'Verify code';

  @override
  String get forgotPasswordInvalidCode => 'Invalid or expired code.';

  @override
  String get forgotPasswordNewPasswordHint => 'New password';

  @override
  String get forgotPasswordConfirmPasswordHint => 'Confirm password';

  @override
  String get forgotPasswordReset => 'Reset password';

  @override
  String get forgotPasswordResetSuccess => 'Password updated. Please log in.';

  @override
  String get continueCta => 'Continue';

  @override
  String get quickSms => 'Fast and secure SMS login';

  @override
  String get newHere => 'New to Curatio? ';

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
  String get staff => 'Doctor / Assistant';

  @override
  String get assistant => 'Assistant';

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
  String get cabinetDefaultPatientNationality => 'Default patient nationality';

  @override
  String get cabinetDefaultCurrency => 'Default currency';

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
  String get cabinetRequestSent => 'Request sent. Awaiting approval.';

  @override
  String get cabinetRequestExists =>
      'Request already sent or already approved.';

  @override
  String get cabinetRequestFailed => 'Could not send request.';

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
  String get cabinetRemoveLastAdminError =>
      'You cannot remove this affiliation because you are the only admin of this clinic.';

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
  String get cabinetStatusPending => 'Pending';

  @override
  String get cabinetStatusRejected => 'Rejected';

  @override
  String get cabinetSelectPendingToast => 'This clinic is pending approval.';

  @override
  String get cabinetSelectRejectedToast => 'This clinic request was rejected.';

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
  String get homeDashNoMoreAppointments => 'No more appointments';

  @override
  String get homePatientSearchEmpty => 'No patients found.';

  @override
  String get homePatientSearchUnnamed => 'Unnamed patient';

  @override
  String get homeMenuConsultation => 'Consultation';

  @override
  String get homeMenuPatientsList => 'Patients';

  @override
  String get homeMenuHistory => 'Log';

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
  String get profileFullNameLabel => 'Full name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileSpecialtyLabel => 'Specialty';

  @override
  String get profileClinicLabel => 'Clinic';

  @override
  String get homeMenuChangeClinic => 'Change clinic';

  @override
  String get homeMenuAdminPanel => 'Admin panel';

  @override
  String get homeMenuLogout => 'Log out';

  @override
  String get adminClinicsTitle => 'Clinics awaiting validation';

  @override
  String get adminClinicsTitlePending => 'Pending clinics';

  @override
  String get adminClinicsTitleApproved => 'Approved clinics';

  @override
  String get adminClinicsTitleCanceled => 'Canceled clinics';

  @override
  String get adminClinicsTitleAll => 'All clinics';

  @override
  String get adminClinicsRefresh => 'Refresh';

  @override
  String get adminClinicsEmpty => 'No pending clinics.';

  @override
  String get adminClinicsPending => 'Pending';

  @override
  String get adminClinicsAll => 'All';

  @override
  String get adminClinicsApproved => 'Approved';

  @override
  String get adminClinicsCanceled => 'Canceled';

  @override
  String get adminClinicsSearchHint => 'Search clinic...';

  @override
  String get adminClinicsApprove => 'Approve';

  @override
  String get adminClinicsReject => 'Reject';

  @override
  String get adminClinicsApproveSuccess => 'Clinic approved.';

  @override
  String get adminClinicsRejectSuccess => 'Clinic rejected.';

  @override
  String get adminClinicsActionFailed => 'Could not update clinic status.';

  @override
  String get adminClinicsUnauthorized =>
      'You are not authorized to access this page.';

  @override
  String get adminClinicsCreatedBy => 'Created by';

  @override
  String get adminClinicsCreatedAt => 'Created at';

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

  @override
  String get footerContactTitle => 'Contact us on :';

  @override
  String get footerContactEmail => 'Email : amor.bouledroua@gmail.com';

  @override
  String get footerContactPhone => 'Phone : (+213) 778 750 333';

  @override
  String get appointmentFilterLabel => 'Filter';

  @override
  String get appointmentFilterDate => 'Date';

  @override
  String get appointmentFilterPeriod => 'Period';

  @override
  String get appointmentFilterAll => 'All';

  @override
  String get appointmentFilterFrom => 'From';

  @override
  String get appointmentFilterTo => 'To';

  @override
  String get appointmentReasonLabel => 'Reason';

  @override
  String appointmentActiveExistsMessage(Object date) {
    return 'This patient already has an active appointment on $date.';
  }

  @override
  String get appointmentCreateSuccess => 'Appointment saved.';

  @override
  String get appointmentCreateFailed => 'Could not save appointment.';

  @override
  String get appointmentPatientRequired => 'Please select a patient.';

  @override
  String get appointmentTimeRequired => 'Please select appointment time.';

  @override
  String get appointmentStatusPresent => 'Present';

  @override
  String get appointmentStatusAbsent => 'Absent';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeBlue => 'Blue';

  @override
  String get settingsThemeRose => 'Pink';

  @override
  String get settingsThemeGreen => 'Green';

  @override
  String get settingsThemePurple => 'Purple';

  @override
  String get settingsGroupGlobal => 'Global';

  @override
  String get settingsGroupAppointment => 'Appointment';

  @override
  String get settingsGroupConsultation => 'Consultation';

  @override
  String get settingsGroupPrinting => 'Printing';

  @override
  String get settingsGroupUsers => 'Users';

  @override
  String get settingsAppointmentWorkingDaysTitle => 'Clinic working days';

  @override
  String get settingsAppointmentOpen => 'Open';

  @override
  String get settingsAppointmentClosed => 'Closed';

  @override
  String get settingsAppointmentMonday => 'Monday';

  @override
  String get settingsAppointmentTuesday => 'Tuesday';

  @override
  String get settingsAppointmentWednesday => 'Wednesday';

  @override
  String get settingsAppointmentThursday => 'Thursday';

  @override
  String get settingsAppointmentFriday => 'Friday';

  @override
  String get settingsAppointmentSaturday => 'Saturday';

  @override
  String get settingsAppointmentSunday => 'Sunday';

  @override
  String get settingsUsersSearchHint => 'Search user...';

  @override
  String get settingsUsersFilterWaiting => 'Waiting for approval';

  @override
  String get settingsUsersFilterApproved => 'Approved';

  @override
  String get settingsUsersFilterAll => 'All';

  @override
  String get settingsUsersAdminBadge => 'Admin';

  @override
  String get settingsUsersApprove => 'Approve';

  @override
  String get settingsUsersCancelApproval => 'Cancel approval';

  @override
  String get settingsUsersMakeAdmin => 'Make admin';

  @override
  String get settingsUsersUnmakeAdmin => 'Unmake admin';

  @override
  String get settingsUsersRoleLabel => 'Role';

  @override
  String get settingsUsersStatusLabel => 'Status';

  @override
  String get settingsUsersUnauthorized =>
      'You are not authorized to manage users in this clinic.';

  @override
  String get settingsUsersLoadFailed => 'Could not load clinic users.';

  @override
  String get settingsUsersEmpty => 'No users found.';

  @override
  String get settingsUsersActionSuccess => 'Action completed.';

  @override
  String get settingsUsersActionFailed => 'Could not complete action.';

  @override
  String get settingsUsersApproveConfirmTitle => 'Approve user';

  @override
  String get settingsUsersApproveConfirmBody =>
      'Are you sure you want to approve this user?';

  @override
  String get settingsUsersCancelConfirmTitle => 'Cancel approval';

  @override
  String get settingsUsersCancelConfirmBody =>
      'Are you sure you want to cancel this user\'s approval?';

  @override
  String get settingsConsultationTogglesTitle => 'Consultation sections';

  @override
  String get settingsConsultationPrescriptionGroupTitle =>
      'Prescription management';

  @override
  String get settingsConsultationPrescriptionModeLabel => 'Prescription mode';

  @override
  String get settingsConsultationPrescriptionModeSelectMedicaments =>
      'Select medications';

  @override
  String get settingsConsultationPrescriptionModeManual =>
      'Manual prescription entry';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get consultationReportsMedical => 'Medical reports';

  @override
  String get consultationSectionLastConsultation => 'Last consultation';

  @override
  String get consultationSectionGeneralInfo => 'General info';

  @override
  String get consultationSectionPrescriptions => 'Prescriptions';

  @override
  String get consultationSectionMedicalCertificate => 'Medical certificate';

  @override
  String get consultationSectionSickLeave => 'Sick leave';

  @override
  String get consultationSectionMedicalCertificates => 'Medical certificates';

  @override
  String get consultationSectionLabs => 'Lab tests';

  @override
  String get consultationSectionOrientationLetter => 'Orientation letter';

  @override
  String get consultationSectionNextAppointment => 'Next appointment';

  @override
  String get consultationSectionLastConsultationDesc =>
      'Summary of the patient\'s last consultation.';

  @override
  String get consultationSectionGeneralInfoDesc =>
      'General consultation information.';

  @override
  String get consultationSectionPrescriptionsDesc =>
      'Add medication and instructions.';

  @override
  String get consultationSectionSickLeaveDesc =>
      'Manage sick leave certificates.';

  @override
  String get consultationSectionMedicalCertificatesDesc =>
      'Create and manage medical certificates.';

  @override
  String get consultationSectionLabsDesc => 'Lab tests and exams requests.';

  @override
  String get consultationSectionOrientationLetterDesc =>
      'Create and manage referral letters.';

  @override
  String get consultationSectionReportsDesc =>
      'Medical notes and report details.';

  @override
  String get consultationSectionNextAppointmentDesc =>
      'Prepare the next appointment.';
}
