/// Shared input validators. Use in Form fields to show clear error messages
/// when the user enters irrelevant or invalid data.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Letters, spaces, hyphens, apostrophes (e.g. John O'Brien, Mary-Jane).
  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s\-'.]+$");

  /// Phone: digits only (optional leading +). Strip spaces/dashes and check length.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your phone number';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    final withPlus = digits.startsWith('+') ? digits.substring(1) : digits;
    if (withPlus.isEmpty) return 'Enter your phone number';
    if (!RegExp(r'^\d+$').hasMatch(withPlus)) {
      return 'Phone number must contain only digits (and optional + at start)';
    }
    if (withPlus.length < 10 || withPlus.length > 15) {
      return 'Enter a valid phone number (10–15 digits)';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Full name: letters and spaces (optional hyphens/apostrophes).
  static String? name(String? value, [String fieldLabel = 'name']) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your $fieldLabel';
    }
    if (!_nameRegex.hasMatch(value.trim())) {
      return '$fieldLabel should contain only letters and spaces';
    }
    if (value.trim().length < 2) {
      return '$fieldLabel must be at least 2 characters';
    }
    return null;
  }

  static String? required(String? value, [String fieldLabel = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
  }

  /// Positive number (e.g. price).
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final n = double.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Price cannot be negative';
    return null;
  }

  /// Non-negative integer (e.g. stock).
  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock is required';
    }
    final n = int.tryParse(value.trim());
    if (n == null) return 'Stock must be a whole number';
    if (n < 0) return 'Stock cannot be negative';
    return null;
  }

  static String? message(String? value, {int minLength = 1}) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < minLength) {
      return 'Message is too short';
    }
    return null;
  }
}
