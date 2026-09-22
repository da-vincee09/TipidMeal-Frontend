import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meal_recommendation_app/app/colors.dart';
import 'package:meal_recommendation_app/core/utils/password_validator.dart';

/// Live password checklist shown under the password field.
///
/// Each rule is a small pill that turns olive with a check as it is met.
/// Once every rule is met the checklist holds for a moment (so the last tick
/// is visible), fades out, and collapses. It comes back if the password
/// stops being valid again.
///
/// The parent's AnimatedSize handles the height change when this collapses.
class PasswordRequirements extends StatefulWidget {
  const PasswordRequirements({
    super.key,
    required this.password,
    this.collapseDelay = const Duration(milliseconds: 700),
  });

  final String password;

  /// How long the fully-ticked checklist stays visible before it disappears.
  final Duration collapseDelay;

  @override
  State<PasswordRequirements> createState() => _PasswordRequirementsState();
}

class _PasswordRequirementsState extends State<PasswordRequirements> {
  Timer? _collapseTimer;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    // If we are (re)built with an already-valid password, stay hidden
    // instead of flashing the checklist again.
    _collapsed = PasswordValidator.isValid(widget.password);
  }

  @override
  void didUpdateWidget(covariant PasswordRequirements oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCollapse();
  }

  void _syncCollapse() {
    if (!PasswordValidator.isValid(widget.password)) {
      _collapseTimer?.cancel();
      _collapseTimer = null;
      _collapsed = false;
      return;
    }

    if (_collapsed || _collapseTimer != null) return;

    _collapseTimer = Timer(widget.collapseDelay, () {
      _collapseTimer = null;
      if (mounted) setState(() => _collapsed = true);
    });
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChildren,
          ?currentChild,
        ],
      ),
      child: _collapsed
          ? const SizedBox(
              key: ValueKey('password-checklist-collapsed'),
              width: double.infinity,
            )
          : _Checklist(
              key: const ValueKey('password-checklist'),
              password: widget.password,
            ),
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final rule in PasswordValidator.rules)
              _RuleChip(label: rule.label, met: rule.isMet(password)),
          ],
        ),
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final idleBackground =
        isDark ? AppColors.darkInputBackground : AppColors.inputBackground;
    final idleForeground =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    final background =
        met ? AppColors.olive.withValues(alpha: 0.16) : idleBackground;
    final foreground = met ? AppColors.olive : idleForeground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              met ? Icons.check_circle : Icons.circle_outlined,
              key: ValueKey(met),
              size: 14,
              color: foreground,
            ),
          ),
          const SizedBox(width: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: met ? FontWeight.w600 : FontWeight.w500,
              color: foreground,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}