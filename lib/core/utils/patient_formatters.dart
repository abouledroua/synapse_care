class PatientFormatters {
  const PatientFormatters._();

  static String formatGs(dynamic gsValue) {
    final gsNumber = gsValue is num ? gsValue.toInt() : int.tryParse(gsValue?.toString() ?? '');
    return switch (gsNumber) {
      1 => 'A+',
      2 => 'A-',
      3 => 'B+',
      4 => 'B-',
      5 => 'AB+',
      6 => 'AB-',
      7 => 'O+',
      8 => 'O-',
      _ => (gsValue ?? '').toString(),
    };
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
    final ageUnit = switch (typeAgeNumber) {
      1 => yearsLabel,
      2 => monthsLabel,
      _ => daysLabel,
    };
    return '${ageValue.toString()} $ageUnit';
  }

  static String formatSexe(dynamic sexeValue, {required String maleLabel, required String femaleLabel}) {
    final sexeNumber = sexeValue is num ? sexeValue.toInt() : int.tryParse(sexeValue?.toString() ?? '');
    if (sexeNumber == 1) return maleLabel;
    if (sexeNumber == 2) return femaleLabel;
    return (sexeValue ?? '').toString();
  }
}
