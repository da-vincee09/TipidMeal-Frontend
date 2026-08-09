import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable slide + fade transition for GoRouter pages.
CustomTransitionPage<void> buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  TransitionType type = TransitionType.slideFromRight,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (type) {
        case TransitionType.slideFromRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );

        case TransitionType.slideFromBottom:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );

        case TransitionType.fade:
          return FadeTransition(opacity: animation, child: child);

        case TransitionType.none:
          return child;
      }
    },
  );
}

enum TransitionType {
  slideFromRight,
  slideFromBottom,
  fade,
  none,
}