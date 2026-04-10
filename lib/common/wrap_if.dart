import 'package:flutter/material.dart';

typedef WidgetChildBuilder = Widget Function(BuildContext context, Widget child);

class WrapIf extends StatelessWidget {
  final bool condition;
  final WidgetChildBuilder wrapper;
  final Widget child;

  const WrapIf({
    super.key,
    required this.condition,
    required this.wrapper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return wrapper(context, child);
    }
    return child;
  }
}
