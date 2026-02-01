import 'package:intl/intl.dart';

class PatientFormatters {
  const PatientFormatters._();

  static String formatGs(dynamic gsValue) {
    final gsNumber = gsValue is num ? gsValue.toInt() : int.tryParse(gsValue?.toString() ?? '');
    switch (gsNumber) {
      case 1:
        return 'A+';
      case 2:
        return 'A-';
      case 3:
        return 'B+';
      case 4:
        return 'B-';
      case 5:
        return 'AB+';
      case 6:
        return 'AB-';
      case 7:
        return 'O+';
      case 8:
        return 'O-';
      default:
        return (gsValue ?? '').toString();
    }
  }

  static String formatAge(
    dynamic ageValue,
    dynamic typeAgeValue, {
    required String yearsLabel,
    required String monthsLabel,
    required String daysLabel,
  }) {
    if (ageValue == null) return '';
    final typeAgeNumber = typeAgeValue is num ? typeAgeValue.toInt() : int.tryParse(typeAgeValue?.toString() ?? '');
    final String ageUnit;
    switch (typeAgeNumber) {
      case 1:
        ageUnit = yearsLabel;
        break;
      case 2:
        ageUnit = monthsLabel;
        break;
      default:
        ageUnit = daysLabel;
    }
    return '${ageValue.toString()} $ageUnit';
  }

  static String formatSexe(dynamic sexeValue, {required String maleLabel, required String femaleLabel}) {
    final sexeNumber = sexeValue is num ? sexeValue.toInt() : int.tryParse(sexeValue?.toString() ?? '');
    if (sexeNumber == 1) return maleLabel;
    if (sexeNumber == 2) return femaleLabel;
    return (sexeValue ?? '').toString();
  }

  static String formatDebt(
    dynamic value, {
    required String localeName,
    required String currencyLatin,
    required String currencyArabic,
  }) {
    if (value == null) return '';
    final amount = value is num ? value : num.tryParse(value.toString());
    if (amount == null) return value.toString();
    final formatted = _formatWithLocale(amount, localeName);
    final isArabic = localeName.startsWith('ar');
    final currency = isArabic ? currencyArabic : currencyLatin;
    return '$formatted $currency';
  }

  static String formatPhone(dynamic value, {int? countryCodeLength}) {
    if (value == null) return '';
    var raw = value.toString().trim();
    if (raw.isEmpty) return '';

    var hasPlus = raw.startsWith('+');
    if (raw.startsWith('00')) {
      raw = '+${raw.substring(2)}';
      hasPlus = true;
    }

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return raw;

    var codeLength = 0;
    if (countryCodeLength != null && countryCodeLength > 0 && countryCodeLength < digits.length) {
      codeLength = countryCodeLength;
    } else if (hasPlus) {
      final match = RegExp(r'^\+(\d{1,3})').firstMatch(raw);
      if (match != null) {
        codeLength = match.group(1)!.length;
      } else {
        codeLength = digits.length >= 3 ? 3 : digits.length;
      }
    }

    if (codeLength > digits.length) {
      codeLength = digits.length;
    }

    final code = codeLength > 0 ? digits.substring(0, codeLength) : '';
    final rest = digits.substring(codeLength);
    if (rest.isEmpty) {
      return code.isEmpty ? digits : '+$code';
    }

    final groups = <String>[];
    for (var i = 0; i < rest.length; i += 3) {
      final end = i + 3 > rest.length ? rest.length : i + 3;
      groups.add(rest.substring(i, end));
    }

    final grouped = groups.join(' ');
    return code.isNotEmpty ? '+$code $grouped' : grouped;
  }

  static String _formatWithLocale(num value, String localeName) {
    try {
      final formatter = NumberFormat.decimalPattern(localeName);
      return formatter.format(value);
    } catch (_) {
      return value.toString();
    }
  }
}
