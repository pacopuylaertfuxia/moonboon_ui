import 'package:flutter/material.dart';

typedef WrapperBuilder = Widget Function(BuildContext context, Widget child);

class WrapIf extends StatelessWidget {
  final bool condition;
  final WrapperBuilder wrapper;
  final Widget child;

  const WrapIf({
    super.key,
    required this.condition,
    required this.wrapper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? wrapper(context, child) : child;
  }
}
