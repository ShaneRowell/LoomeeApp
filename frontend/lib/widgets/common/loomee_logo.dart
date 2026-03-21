import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LomeeLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const LomeeLogo({
    super.key,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    return SvgPicture.asset(
      'assets/images/loomee_logo.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
