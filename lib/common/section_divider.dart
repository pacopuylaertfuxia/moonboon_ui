import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 16,
      color: context.color.borderSubdued,
      thickness: 1,
    );
  }
}
