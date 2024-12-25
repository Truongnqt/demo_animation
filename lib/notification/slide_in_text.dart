import 'package:flutter/material.dart';

class SlideInText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool show;
  final Duration duration;

  const SlideInText({
    super.key,
    required this.text,
    required this.style,
    required this.show,
    this.duration = const Duration(milliseconds: 1700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.linear,
      tween: Tween<double>(begin: 0, end: show ? 1 : 0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-1 * (1 - value), 0),
            child: Text(text, style: style),
          ),
        );
      },
    );
  }
}
