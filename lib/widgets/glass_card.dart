import 'package:flutter/material.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final Color? glowColor;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blurSigma = 18.0,
    this.glowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (glowColor != null)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: RadialGradient(
                  colors: [glowColor!.withOpacity(0.08), glowColor!.withOpacity(0)],
                ),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1A15).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFFEFE9E1).withOpacity(0.12),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ],
    );
  }
}