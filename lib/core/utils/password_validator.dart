/// One password rule: a short label users read, plus the check behind it.
class PasswordRule {
  const PasswordRule({required this.label, required this.isMet});

  final String label;
  final bool Function(String password) isMet;
}

/// Single source of truth for password strength.
///
/// Keep this in sync with the Auth settings in the Supabase dashboard
/// (minimum length + required character types), so a password that passes
/// this form is never rejected by the server.
class PasswordValidator {
  PasswordValidator._();

  static const int minLength = 8;

  // Symbols Supabase accepts:
  // !@#$%^&*()_+-=[]{};'\:"|<>?,./`~
  static final RegExp _symbol =
      RegExp(r'''[!@#$%^&*()_+\-=\[\]{};':"\\|<>?,./`~]''');
  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _lower = RegExp(r'[a-z]');
  static final RegExp _digit = RegExp(r'[0-9]');

  static final List<PasswordRule> rules = [
    PasswordRule(
      label: 'At least $minLength characters',
      isMet: (p) => p.length >= minLength,
    ),
    PasswordRule(
      label: 'Uppercase letter',
      isMet: (p) => _upper.hasMatch(p),
    ),
    PasswordRule(
      label: 'Lowercase letter',
      isMet: (p) => _lower.hasMatch(p),
    ),
    PasswordRule(
      label: 'Number',
      isMet: (p) => _digit.hasMatch(p),
    ),
    PasswordRule(
      label: 'Symbol (! @ #)',
      isMet: (p) => _symbol.hasMatch(p),
    ),
  ];

  /// True when every rule is satisfied.
  static bool isValid(String password) =>
      rules.every((rule) => rule.isMet(password));

  /// Labels of the rules the password still fails (empty when valid).
  static List<String> unmetLabels(String password) => [
        for (final rule in rules)
          if (!rule.isMet(password)) rule.label,
      ];
}