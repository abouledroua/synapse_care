import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Curatio'**
  String get appTitle;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Intelligent platform for care management and patient follow-up.'**
  String get brandTagline;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Curatio'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'The intelligent platform for care management and patient follow-up.'**
  String get welcomeBody;

  /// No description provided for @accessSpace.
  ///
  /// In en, this message translates to:
  /// **'Access the application space'**
  String get accessSpace;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @patientListTitle.
  ///
  /// In en, this message translates to:
  /// **'List of Patients'**
  String get patientListTitle;

  /// No description provided for @patientListAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Patient'**
  String get patientListAddNew;

  /// No description provided for @patientListRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get patientListRefresh;

  /// No description provided for @patientListAddComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get patientListAddComingSoon;

  /// No description provided for @patientHeaderFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get patientHeaderFullName;

  /// No description provided for @patientHeaderSexe.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get patientHeaderSexe;

  /// No description provided for @patientHeaderAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get patientHeaderAge;

  /// No description provided for @patientHeaderPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get patientHeaderPhone;

  /// No description provided for @patientHeaderAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get patientHeaderAddress;

  /// No description provided for @patientHeaderDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get patientHeaderDebt;

  /// No description provided for @patientHeaderBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get patientHeaderBloodGroup;

  /// No description provided for @patientHeaderActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get patientHeaderActions;

  /// No description provided for @patientHeaderNin.
  ///
  /// In en, this message translates to:
  /// **'NIN'**
  String get patientHeaderNin;

  /// No description provided for @patientHeaderNss.
  ///
  /// In en, this message translates to:
  /// **'NSS'**
  String get patientHeaderNss;

  /// No description provided for @patientHeaderEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get patientHeaderEmail;

  /// No description provided for @patientSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get patientSexMale;

  /// No description provided for @patientSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get patientSexFemale;

  /// No description provided for @patientActionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get patientActionUpdate;

  /// No description provided for @patientActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get patientActionDelete;

  /// No description provided for @patientAgeYears.
  ///
  /// In en, this message translates to:
  /// **'year(s)'**
  String get patientAgeYears;

  /// No description provided for @patientAgeMonths.
  ///
  /// In en, this message translates to:
  /// **'month(s)'**
  String get patientAgeMonths;

  /// No description provided for @patientAgeDays.
  ///
  /// In en, this message translates to:
  /// **'day(s)'**
  String get patientAgeDays;

  /// No description provided for @patientCurrencyDzdLatin.
  ///
  /// In en, this message translates to:
  /// **'DA'**
  String get patientCurrencyDzdLatin;

  /// No description provided for @patientCurrencyDzdArabic.
  ///
  /// In en, this message translates to:
  /// **'دج'**
  String get patientCurrencyDzdArabic;

  /// No description provided for @patientCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Patient'**
  String get patientCreateTitle;

  /// No description provided for @patientEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get patientEditTitle;

  /// No description provided for @patientEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient updated'**
  String get patientEditSuccess;

  /// No description provided for @patientEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update patient'**
  String get patientEditFailed;

  /// No description provided for @patientDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete patient'**
  String get patientDeleteConfirmTitle;

  /// No description provided for @patientDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this patient?'**
  String get patientDeleteConfirmBody;

  /// No description provided for @patientDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get patientDeleteCancel;

  /// No description provided for @patientDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get patientDeleteConfirm;

  /// No description provided for @patientDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient deleted'**
  String get patientDeleteSuccess;

  /// No description provided for @patientDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete patient'**
  String get patientDeleteFailed;

  /// No description provided for @patientCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get patientCreateSubmit;

  /// No description provided for @patientCreateSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get patientCreateSaving;

  /// No description provided for @patientCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient created.'**
  String get patientCreateSuccess;

  /// No description provided for @patientCreateLinked.
  ///
  /// In en, this message translates to:
  /// **'Patient already exists. Linked to this clinic.'**
  String get patientCreateLinked;

  /// No description provided for @patientLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient exists'**
  String get patientLinkTitle;

  /// No description provided for @patientLinkBody.
  ///
  /// In en, this message translates to:
  /// **'This patient already exists. Do you want to link them to this clinic?'**
  String get patientLinkBody;

  /// No description provided for @patientLinkConfirm.
  ///
  /// In en, this message translates to:
  /// **'Link patient'**
  String get patientLinkConfirm;

  /// No description provided for @patientLinkCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get patientLinkCancel;

  /// No description provided for @patientLinkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient linked to this clinic.'**
  String get patientLinkSuccess;

  /// No description provided for @patientLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not link patient.'**
  String get patientLinkFailed;

  /// No description provided for @patientCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create patient.'**
  String get patientCreateFailed;

  /// No description provided for @patientSectionIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get patientSectionIdentity;

  /// No description provided for @patientSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get patientSectionContact;

  /// No description provided for @patientSectionInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get patientSectionInsurance;

  /// No description provided for @patientFieldCodeBarre.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get patientFieldCodeBarre;

  /// No description provided for @patientFieldNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get patientFieldNationality;

  /// No description provided for @patientNationalityAlgeria.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get patientNationalityAlgeria;

  /// No description provided for @patientNationalityFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get patientNationalityFrance;

  /// No description provided for @patientNationalityOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get patientNationalityOther;

  /// No description provided for @patientFieldNom.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get patientFieldNom;

  /// No description provided for @patientFieldPrenom.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get patientFieldPrenom;

  /// No description provided for @patientFieldDateNaissance.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get patientFieldDateNaissance;

  /// No description provided for @patientFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get patientFieldEmail;

  /// No description provided for @patientFieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get patientFieldAge;

  /// No description provided for @patientFieldTel1.
  ///
  /// In en, this message translates to:
  /// **'Phone 1'**
  String get patientFieldTel1;

  /// No description provided for @patientFieldTel2.
  ///
  /// In en, this message translates to:
  /// **'Phone 2'**
  String get patientFieldTel2;

  /// No description provided for @patientFieldWilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get patientFieldWilaya;

  /// No description provided for @patientFieldApc.
  ///
  /// In en, this message translates to:
  /// **'APC'**
  String get patientFieldApc;

  /// No description provided for @patientFieldAdresse.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get patientFieldAdresse;

  /// No description provided for @patientFieldDette.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get patientFieldDette;

  /// No description provided for @patientFieldPresume.
  ///
  /// In en, this message translates to:
  /// **'Presumed'**
  String get patientFieldPresume;

  /// No description provided for @patientFieldSexe.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get patientFieldSexe;

  /// No description provided for @patientFieldTypeAge.
  ///
  /// In en, this message translates to:
  /// **'Age unit'**
  String get patientFieldTypeAge;

  /// No description provided for @patientFieldConventionne.
  ///
  /// In en, this message translates to:
  /// **'Insured'**
  String get patientFieldConventionne;

  /// No description provided for @patientFieldPourcConv.
  ///
  /// In en, this message translates to:
  /// **'Coverage (%)'**
  String get patientFieldPourcConv;

  /// No description provided for @patientFieldLieuNaissance.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get patientFieldLieuNaissance;

  /// No description provided for @patientFieldGs.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get patientFieldGs;

  /// No description provided for @patientFieldProfession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get patientFieldProfession;

  /// No description provided for @patientFieldDiagnostique.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get patientFieldDiagnostique;

  /// No description provided for @patientFieldNin.
  ///
  /// In en, this message translates to:
  /// **'NIN'**
  String get patientFieldNin;

  /// No description provided for @patientFieldNss.
  ///
  /// In en, this message translates to:
  /// **'NSS'**
  String get patientFieldNss;

  /// No description provided for @patientFieldNbImpression.
  ///
  /// In en, this message translates to:
  /// **'Print count'**
  String get patientFieldNbImpression;

  /// No description provided for @patientFieldCodeMalade.
  ///
  /// In en, this message translates to:
  /// **'Patient code'**
  String get patientFieldCodeMalade;

  /// No description provided for @patientFieldPhotoUrl.
  ///
  /// In en, this message translates to:
  /// **'Photo URL'**
  String get patientFieldPhotoUrl;

  /// No description provided for @patientClinicRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a clinic first.'**
  String get patientClinicRequired;

  /// No description provided for @patientOptionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get patientOptionYes;

  /// No description provided for @patientOptionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get patientOptionNo;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get fieldRequired;

  /// No description provided for @fieldInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get fieldInvalidNumber;

  /// No description provided for @patientListUpdateComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Update coming soon'**
  String get patientListUpdateComingSoon;

  /// No description provided for @patientListDeleteComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Delete coming soon'**
  String get patientListDeleteComingSoon;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The requested URL does not exist.'**
  String get notFoundBody;

  /// No description provided for @notFoundCode.
  ///
  /// In en, this message translates to:
  /// **'404'**
  String get notFoundCode;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @accessDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get accessDeniedTitle;

  /// No description provided for @accessDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get accessDeniedBody;

  /// No description provided for @backHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHomeCta;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed.'**
  String get signupFailed;

  /// No description provided for @signupEmailExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists.'**
  String get signupEmailExists;

  /// No description provided for @signupPhoneExists.
  ///
  /// In en, this message translates to:
  /// **'Phone number already exists.'**
  String get signupPhoneExists;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailHint;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameHint;

  /// No description provided for @specialtyHint.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialtyHint;

  /// No description provided for @nameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get nameEmptyError;

  /// No description provided for @emailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emailEmptyError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalidError;

  /// No description provided for @specialtyEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your specialty'**
  String get specialtyEmptyError;

  /// No description provided for @passwordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordEmptyError;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email or password are wrong'**
  String get loginInvalid;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @loginNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the server. Please check your internet connection.'**
  String get loginNetworkError;

  /// No description provided for @timeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get timeoutTitle;

  /// No description provided for @timeoutBody.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to the login page in 5 seconds.'**
  String get timeoutBody;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordNeedSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must include . , + * or ?'**
  String get passwordNeedSpecial;

  /// No description provided for @passwordNeedUpper.
  ///
  /// In en, this message translates to:
  /// **'Password must include one capital letter'**
  String get passwordNeedUpper;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get forgotPasswordSending;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'If the email exists, a reset link was sent.'**
  String get forgotPasswordSuccess;

  /// No description provided for @forgotPasswordCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent. Check your email.'**
  String get forgotPasswordCodeSent;

  /// No description provided for @forgotPasswordEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email does not exist.'**
  String get forgotPasswordEmailNotFound;

  /// No description provided for @forgotPasswordCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get forgotPasswordCodeHint;

  /// No description provided for @forgotPasswordVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get forgotPasswordVerify;

  /// No description provided for @forgotPasswordInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code.'**
  String get forgotPasswordInvalidCode;

  /// No description provided for @forgotPasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get forgotPasswordNewPasswordHint;

  /// No description provided for @forgotPasswordConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get forgotPasswordConfirmPasswordHint;

  /// No description provided for @forgotPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordReset;

  /// No description provided for @forgotPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please log in.'**
  String get forgotPasswordResetSuccess;

  /// No description provided for @continueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCta;

  /// No description provided for @quickSms.
  ///
  /// In en, this message translates to:
  /// **'Fast and secure SMS login'**
  String get quickSms;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New to Curatio? '**
  String get newHere;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Assistant'**
  String get staff;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistant;

  /// No description provided for @cabinetSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your medical clinic'**
  String get cabinetSearchTitle;

  /// No description provided for @cabinetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your medical clinic'**
  String get cabinetSearchHint;

  /// No description provided for @cabinetSearchHelper.
  ///
  /// In en, this message translates to:
  /// **'Search by name, city, or specialty.'**
  String get cabinetSearchHelper;

  /// No description provided for @cabinetSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No clinics found.'**
  String get cabinetSearchEmpty;

  /// No description provided for @cabinetSearchAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Clinic'**
  String get cabinetSearchAddNew;

  /// No description provided for @cabinetSearchAddNewComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get cabinetSearchAddNewComingSoon;

  /// No description provided for @cabinetCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new clinic'**
  String get cabinetCreateTitle;

  /// No description provided for @cabinetCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create clinic'**
  String get cabinetCreateSubmit;

  /// No description provided for @cabinetDefaultPatientNationality.
  ///
  /// In en, this message translates to:
  /// **'Default patient nationality'**
  String get cabinetDefaultPatientNationality;

  /// No description provided for @cabinetDefaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get cabinetDefaultCurrency;

  /// No description provided for @cabinetNameHint.
  ///
  /// In en, this message translates to:
  /// **'Clinic name'**
  String get cabinetNameHint;

  /// No description provided for @cabinetNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the clinic name'**
  String get cabinetNameEmptyError;

  /// No description provided for @cabinetAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Clinic address'**
  String get cabinetAddressHint;

  /// No description provided for @cabinetAddressEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the clinic address'**
  String get cabinetAddressEmptyError;

  /// No description provided for @cabinetAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Clinic added successfully.'**
  String get cabinetAddSuccess;

  /// No description provided for @cabinetAddExists.
  ///
  /// In en, this message translates to:
  /// **'Clinic already added.'**
  String get cabinetAddExists;

  /// No description provided for @cabinetAddFailed.
  ///
  /// In en, this message translates to:
  /// **'could not add clinic'**
  String get cabinetAddFailed;

  /// No description provided for @cabinetRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. Awaiting approval.'**
  String get cabinetRequestSent;

  /// No description provided for @cabinetRequestExists.
  ///
  /// In en, this message translates to:
  /// **'Request already sent or already approved.'**
  String get cabinetRequestExists;

  /// No description provided for @cabinetRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send request.'**
  String get cabinetRequestFailed;

  /// No description provided for @cabinetRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cabinetRemoveAction;

  /// No description provided for @cabinetRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove clinic?'**
  String get cabinetRemoveConfirmTitle;

  /// No description provided for @cabinetRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove your affiliation with this clinic.'**
  String get cabinetRemoveConfirmBody;

  /// No description provided for @cabinetRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cabinetRemoveConfirm;

  /// No description provided for @cabinetRemoveCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cabinetRemoveCancel;

  /// No description provided for @cabinetRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Clinic removed.'**
  String get cabinetRemoveSuccess;

  /// No description provided for @cabinetRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove clinic.'**
  String get cabinetRemoveFailed;

  /// No description provided for @cabinetRemoveLastAdminError.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove this affiliation because you are the only admin of this clinic.'**
  String get cabinetRemoveLastAdminError;

  /// No description provided for @cabinetSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your clinic'**
  String get cabinetSelectTitle;

  /// No description provided for @cabinetSelectBody.
  ///
  /// In en, this message translates to:
  /// **'Select the medical clinic you are affiliated with.'**
  String get cabinetSelectBody;

  /// No description provided for @cabinetSelectSampleSpecialty.
  ///
  /// In en, this message translates to:
  /// **'General medicine'**
  String get cabinetSelectSampleSpecialty;

  /// No description provided for @cabinetSelectEmpty.
  ///
  /// In en, this message translates to:
  /// **'No affiliated clinics found.'**
  String get cabinetSelectEmpty;

  /// No description provided for @cabinetStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get cabinetStatusPending;

  /// No description provided for @cabinetStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get cabinetStatusRejected;

  /// No description provided for @cabinetSelectPendingToast.
  ///
  /// In en, this message translates to:
  /// **'This clinic is pending approval.'**
  String get cabinetSelectPendingToast;

  /// No description provided for @cabinetSelectRejectedToast.
  ///
  /// In en, this message translates to:
  /// **'This clinic request was rejected.'**
  String get cabinetSelectRejectedToast;

  /// No description provided for @cabinetSelectUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed clinic'**
  String get cabinetSelectUnnamed;

  /// No description provided for @cabinetSelectAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a clinic'**
  String get cabinetSelectAdd;

  /// No description provided for @cabinetSelectFind.
  ///
  /// In en, this message translates to:
  /// **'Find a clinic'**
  String get cabinetSelectFind;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Rechercher...'**
  String get homeSearchHint;

  /// No description provided for @homeDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboardTitle;

  /// No description provided for @homeDashAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get homeDashAppointments;

  /// No description provided for @homeDashConsultationsToday.
  ///
  /// In en, this message translates to:
  /// **'Consultations today'**
  String get homeDashConsultationsToday;

  /// No description provided for @homeDashPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get homeDashPatients;

  /// No description provided for @homeDashRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get homeDashRevenue;

  /// No description provided for @homeDashAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get homeDashAlerts;

  /// No description provided for @homeDashConsultationsMonth.
  ///
  /// In en, this message translates to:
  /// **'Consultations this month'**
  String get homeDashConsultationsMonth;

  /// No description provided for @homeDashNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Next appointment'**
  String get homeDashNextTitle;

  /// No description provided for @homeDashNextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'09:30 • Amina B. • Consultation'**
  String get homeDashNextSubtitle;

  /// No description provided for @homePatientSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No patients found.'**
  String get homePatientSearchEmpty;

  /// No description provided for @homePatientSearchUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed patient'**
  String get homePatientSearchUnnamed;

  /// No description provided for @homeMenuConsultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get homeMenuConsultation;

  /// No description provided for @homeMenuPatientsList.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get homeMenuPatientsList;

  /// No description provided for @homeMenuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeMenuHistory;

  /// No description provided for @homeMenuCaisse.
  ///
  /// In en, this message translates to:
  /// **'Caisse'**
  String get homeMenuCaisse;

  /// No description provided for @homeMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeMenuSettings;

  /// No description provided for @homeMenuData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get homeMenuData;

  /// No description provided for @homeMenuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get homeMenuAbout;

  /// No description provided for @homeMenuToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeMenuToday;

  /// No description provided for @homeMenuRdvTake.
  ///
  /// In en, this message translates to:
  /// **'Take appointment'**
  String get homeMenuRdvTake;

  /// No description provided for @homeMenuRdvList.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get homeMenuRdvList;

  /// No description provided for @homeMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get homeMenuProfile;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileSpecialtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get profileSpecialtyLabel;

  /// No description provided for @profileClinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get profileClinicLabel;

  /// No description provided for @homeMenuChangeClinic.
  ///
  /// In en, this message translates to:
  /// **'Change clinic'**
  String get homeMenuChangeClinic;

  /// No description provided for @homeMenuAdminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get homeMenuAdminPanel;

  /// No description provided for @homeMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get homeMenuLogout;

  /// No description provided for @adminClinicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinics awaiting validation'**
  String get adminClinicsTitle;

  /// No description provided for @adminClinicsTitlePending.
  ///
  /// In en, this message translates to:
  /// **'Pending clinics'**
  String get adminClinicsTitlePending;

  /// No description provided for @adminClinicsTitleApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved clinics'**
  String get adminClinicsTitleApproved;

  /// No description provided for @adminClinicsTitleCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled clinics'**
  String get adminClinicsTitleCanceled;

  /// No description provided for @adminClinicsTitleAll.
  ///
  /// In en, this message translates to:
  /// **'All clinics'**
  String get adminClinicsTitleAll;

  /// No description provided for @adminClinicsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminClinicsRefresh;

  /// No description provided for @adminClinicsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending clinics.'**
  String get adminClinicsEmpty;

  /// No description provided for @adminClinicsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminClinicsPending;

  /// No description provided for @adminClinicsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminClinicsAll;

  /// No description provided for @adminClinicsApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminClinicsApproved;

  /// No description provided for @adminClinicsCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get adminClinicsCanceled;

  /// No description provided for @adminClinicsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search clinic...'**
  String get adminClinicsSearchHint;

  /// No description provided for @adminClinicsApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminClinicsApprove;

  /// No description provided for @adminClinicsReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminClinicsReject;

  /// No description provided for @adminClinicsApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Clinic approved.'**
  String get adminClinicsApproveSuccess;

  /// No description provided for @adminClinicsRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Clinic rejected.'**
  String get adminClinicsRejectSuccess;

  /// No description provided for @adminClinicsActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update clinic status.'**
  String get adminClinicsActionFailed;

  /// No description provided for @adminClinicsUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this page.'**
  String get adminClinicsUnauthorized;

  /// No description provided for @adminClinicsCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get adminClinicsCreatedBy;

  /// No description provided for @adminClinicsCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get adminClinicsCreatedAt;

  /// No description provided for @homeMenuOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get homeMenuOpenTooltip;

  /// No description provided for @homeLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get homeLogoutConfirmMessage;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Dr. {name}'**
  String homeGreeting(Object name);

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneHint;

  /// No description provided for @phoneEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get phoneEmptyError;

  /// No description provided for @phoneInvalidPrefixError.
  ///
  /// In en, this message translates to:
  /// **'Number must start with 5, 6, or 7'**
  String get phoneInvalidPrefixError;

  /// No description provided for @otpSend.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP code to {phone}'**
  String otpSend(Object phone);

  /// No description provided for @otpValidDemo.
  ///
  /// In en, this message translates to:
  /// **'This {phone} is valid for the demo.'**
  String otpValidDemo(Object phone);
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
