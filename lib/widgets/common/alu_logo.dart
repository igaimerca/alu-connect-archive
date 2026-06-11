import 'package:flutter/material.dart';

class AluLogo extends StatelessWidget {
  const AluLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.school_rounded,
        size: size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
