// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سينابس كير';

  @override
  String get brandTagline => 'منصة ذكية لإدارة الرعاية ومتابعة المرضى.';

  @override
  String get welcomeHeadline => 'مرحبًا بك في سينابس كير';

  @override
  String get welcomeBody => 'المنصة الذكية لإدارة الرعاية ومتابعة المرضى.';

  @override
  String get accessSpace => 'الدخول إلى التطبيق';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundBody => 'الرابط المطلوب غير موجود.';

  @override
  String get backHome => 'العودة إلى الصفحة الرئيسية';

  @override
  String get accessDeniedTitle => 'تم رفض الوصول';

  @override
  String get accessDeniedBody => 'ليس لديك إذن للوصول إلى هذه الصفحة.';

  @override
  String get backHomeCta => 'العودة إلى الصفحة الرئيسية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get nameHint => 'الاسم الكامل';

  @override
  String get specialtyHint => 'التخصص';

  @override
  String get nameEmptyError => 'يرجى إدخال الاسم الكامل';

  @override
  String get emailEmptyError => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get emailInvalidError => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get specialtyEmptyError => 'يرجى إدخال التخصص';

  @override
  String get passwordEmptyError => 'يرجى إدخال كلمة المرور';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get loginInvalid => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get loginNetworkError =>
      'لا يمكن الوصول إلى الخادم, يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get timeoutTitle => 'انتهت صلاحية الجلسة';

  @override
  String get timeoutBody => 'سيتم تحويلك إلى صفحة تسجيل الدخول خلال 5 ثوانٍ.';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get passwordTooShort => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get passwordNeedSpecial =>
      'يجب أن تحتوي كلمة المرور على . أو , أو + أو * أو ؟';

  @override
  String get passwordNeedUpper => 'يجب أن تحتوي كلمة المرور على حرف كبير واحد';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get continueCta => 'متابعة';

  @override
  String get quickSms => 'تسجيل دخول سريع وآمن عبر الرسائل القصيرة';

  @override
  String get newHere => 'مستخدم جديد في سينابس كير؟ ';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get patient => 'مريض';

  @override
  String get doctor => 'طبيب';

  @override
  String get cabinetSearchTitle => 'ابحث عن عيادتك الطبية';

  @override
  String get cabinetSearchHint => 'ابحث عن عيادتك الطبية';

  @override
  String get cabinetSearchHelper => 'ابحث بالاسم أو المدينة أو التخصص.';

  @override
  String get cabinetSearchEmpty => 'لم يتم العثور على عيادات.';

  @override
  String get cabinetAddSuccess => 'تمت إضافة العيادة بنجاح.';

  @override
  String get cabinetAddExists => 'تمت إضافة العيادة مسبقًا.';

  @override
  String get cabinetAddFailed => 'تعذر إضافة العيادة.';

  @override
  String get cabinetSelectTitle => 'اختر عيادتك';

  @override
  String get cabinetSelectBody => 'حدد العيادة الطبية التي تنتمي إليها.';

  @override
  String get cabinetSelectSampleSpecialty => 'طب عام';

  @override
  String get cabinetSelectEmpty => 'لم يتم العثور على عيادات مرتبطة.';

  @override
  String get cabinetSelectUnnamed => 'عيادة بدون اسم';

  @override
  String get cabinetSelectAdd => 'إضافة عيادة';

  @override
  String get cabinetSelectFind => 'البحث عن عيادة';

  @override
  String get homeSearchHint => 'ابحث...';

  @override
  String get homeMenuConsultation => 'استشارة';

  @override
  String get homeMenuHistory => 'السجل';

  @override
  String get homeMenuCaisse => 'الصندوق';

  @override
  String get homeMenuSettings => 'الإعدادات';

  @override
  String get homeMenuData => 'البيانات';

  @override
  String get homeMenuAbout => 'حول';

  @override
  String get homeMenuToday => 'اليوم';

  @override
  String get homeMenuRdvTake => 'أخذ موعد';

  @override
  String get homeMenuRdvList => 'قائمة المواعيد';

  @override
  String get homeMenuProfile => 'ملفي الشخصي';

  @override
  String get homeMenuChangeClinic => 'تغيير العيادة';

  @override
  String get homeMenuLogout => 'تسجيل الخروج';

  @override
  String get phoneHint => 'رقم الهاتف';

  @override
  String get phoneEmptyError => 'يرجى إدخال رقم الهاتف';

  @override
  String get phoneInvalidPrefixError => 'يجب أن يبدأ الرقم بـ 5 أو 6 أو 7';

  @override
  String otpSend(Object phone) {
    return 'يتم إرسال رمز OTP إلى $phone';
  }

  @override
  String otpValidDemo(Object phone) {
    return 'هذا الرقم $phone صالح للتجربة.';
  }
}
