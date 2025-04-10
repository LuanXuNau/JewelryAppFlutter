import 'package:flutter/material.dart';

/// Dùng như sau:
/// Navigator.push(context, RotationRoute(page: NextPage()));
class RotationRoute extends PageRouteBuilder {
  final Widget page;

  RotationRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            );
            final scale = Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}
