import 'dart:async';
import 'package:demo_animation/notification/border_painter.dart';
import 'package:demo_animation/notification/slide_in_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: AnimateNotification(),
        ),
      ),
    ),
  ));
}

class AnimateNotification extends ConsumerStatefulWidget {
  const AnimateNotification({super.key});

  @override
  ConsumerState<AnimateNotification> createState() =>
      _AnimateNotificationState();
}

class _AnimateNotificationState extends ConsumerState<AnimateNotification>
    with SingleTickerProviderStateMixin {
  bool _isShow = false;
  bool _isIconMoving = true;
  bool _showText1 = false;
  bool _showText2 = false;
  bool _showBorder = false;
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  Timer? _timerShow;
  String _pharseTex1 = '혹시 심심하신가요?';
  String _pharseTex2 = '버튼을 눌러 보세요';

  final List<Gradient> _gradients = [
    const LinearGradient(colors: [Colors.purple, Colors.pink]),
    const LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent]),
    const LinearGradient(colors: [Colors.blue, Colors.deepOrangeAccent]),
  ];

  int _gradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: getRunTime(_pharseTex1)),
    );
    double centerPosition = _textWidth(_pharseTex1, _textStyle) + 76;
    _iconAnimation = Tween<double>(begin: 0, end: centerPosition).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.linear),
      ),
    )
      ..addListener(() {
        setState(() {
          _gradientIndex = (_controller.value * _gradients.length).toInt() %
              _gradients.length;
        });
        if (_controller.value >= 0.6 && !_showText1) {
          setState(() {
            _showText1 = true;
            _startText2Animation();
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isShow = true;
            _isIconMoving = false;
          });
        }
      });

    Future.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        _showBorder = true;
      });
    });
  }

  int getRunTime(String text) {
    return text.length * 155;
  }

  void _startText2Animation() {
    _isIconMoving = false;
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _showText2 = true;
      });
    });
  }

  void _startIconAnimation() {
    if (_isShow) {
      setState(() {
        _isShow = false;
        _isIconMoving = true;
        _showText1 = false;
        _showText2 = false;
      });
      _controller.reset();
    } else {
      setState(() {
        _isShow = true;
        _isIconMoving = true;
        _showText1 = false;
        _showText2 = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timerShow?.cancel();
    super.dispose();
  }

  final TextStyle _textStyle = const TextStyle(
      fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500);

  double _textWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final double _width = _textWidth(_pharseTex1, _textStyle);
    final double _fullWidth = _textWidth(_pharseTex2, _textStyle);
    final double totalWidth = _width + _fullWidth + 65;

    return GestureDetector(
      onTap: _startIconAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double targetWidth = _isShow ? totalWidth : 60;
            return Stack(
              children: [
                PositionedDirectional(
                  start: 30,
                  child: AnimatedContainer(
                    width: targetWidth,
                    height: 70,
                    duration: const Duration(milliseconds: 2100),
                    curve: Curves.linear,
                    child: _isShow && _showBorder
                        ? CustomPaint(
                            painter: BorderPainter(
                              width: targetWidth,
                              height: 70,
                              strokeWidth: 2,
                              gradient: _gradients[_gradientIndex],
                            ),
                          )
                        : null,
                  ),
                ),
                if (_showText1)
                  PositionedDirectional(
                    start: 40,
                    top: 20,
                    child: SlideInText(
                      text: _pharseTex1,
                      style: _textStyle,
                      show: _showText1,
                      duration: Duration(milliseconds: getRunTime(_pharseTex1)),
                    ),
                  ),
                PositionedDirectional(
                  start:
                      _isIconMoving ? _iconAnimation.value + 40 : _width + 40,
                  top: 20,
                  child: GestureDetector(
                    onTap: _startIconAnimation,
                    child: Icon(
                      Icons.notifications,
                      color: Colors.black,
                      size: 35,
                    ),
                  ),
                ),
                if (_showText2)
                  PositionedDirectional(
                    start: _width + 76,
                    top: 20,
                    child: SlideInText(
                      text: _pharseTex2,
                      style: _textStyle,
                      show: _showText2,
                      duration: const Duration(milliseconds: 150),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
