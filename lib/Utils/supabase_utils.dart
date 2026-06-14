String toAuthEmail(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

  final last10 = digits.length >= 10
      ? digits.substring(digits.length - 10)
      : digits;

  return '$last10@raithan.app';
}