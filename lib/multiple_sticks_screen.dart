import 'package:flutter/material.dart';

// Theme configuration class
class StickTheme {
  final double ballSize;
  final double stickStart;
  final double lineWidth;
  final double lineHeight;
  final double verticalSpacing;
  final Color ballColor;
  final Color verticalLineColor;
  final Color horizontalLineColor;
  final Color ballShadowColor;

  const StickTheme({
    this.ballSize = 25.0,
    this.stickStart = 10.0,
    this.lineWidth = 4.0,
    this.lineHeight = 40.0,
    this.verticalSpacing = 40.0,
    required this.ballColor,
    required this.verticalLineColor,
    required this.horizontalLineColor,
    required this.ballShadowColor,
  });

  // Factory constructors for light and dark themes
  factory StickTheme.light() {
    return const StickTheme(
      ballColor: Colors.blue,
      verticalLineColor: Colors.black87,
      horizontalLineColor: Colors.brown,
      ballShadowColor: Colors.black26,
    );
  }

  factory StickTheme.dark() {
    return const StickTheme(
      ballColor: Colors.lightBlueAccent,
      verticalLineColor: Colors.white70,
      horizontalLineColor: Colors.brown,
      ballShadowColor: Colors.black87,
    );
  }

  // Create a copy with some properties changed
  StickTheme copyWith({
    double? ballSize,
    double? stickStart,
    double? lineWidth,
    double? lineHeight,
    double? verticalSpacing,
    Color? ballColor,
    Color? verticalLineColor,
    Color? horizontalLineColor,
    Color? ballShadowColor,
  }) {
    return StickTheme(
      ballSize: ballSize ?? this.ballSize,
      stickStart: stickStart ?? this.stickStart,
      lineWidth: lineWidth ?? this.lineWidth,
      lineHeight: lineHeight ?? this.lineHeight,
      verticalSpacing: verticalSpacing ?? this.verticalSpacing,
      ballColor: ballColor ?? this.ballColor,
      verticalLineColor: verticalLineColor ?? this.verticalLineColor,
      horizontalLineColor: horizontalLineColor ?? this.horizontalLineColor,
      ballShadowColor: ballShadowColor ?? this.ballShadowColor,
    );
  }
}

class MultipleSticks extends StatefulWidget {
  final StickTheme theme;
  final int numberOfSticks;

  const MultipleSticks({
    super.key,
    this.theme = const StickTheme(
      ballColor: Colors.blue,
      verticalLineColor: Colors.black87,
      horizontalLineColor: Colors.brown,
      ballShadowColor: Colors.black26,
    ),
    this.numberOfSticks = 17,
  });

  @override
  _MultipleSticksState createState() => _MultipleSticksState();
}

class _MultipleSticksState extends State<MultipleSticks> {
  late List<List<ValueNotifier<double>>> stickSections;
  late List<double> section1Widths;
  late List<double> section2Widths;
  late List<double> maxSection1Positions;
  late List<double> maxSection2Positions;

  @override
  void initState() {
    super.initState();
    _initializeSticks();
  }

  void _initializeSticks() {
    stickSections = List.generate(widget.numberOfSticks, (stickIndex) {
      return [
        ...List.generate(4, (index) => ValueNotifier(0.0)),
        ValueNotifier(0.0)
      ];
    });
    section1Widths = List.filled(widget.numberOfSticks, 0);
    section2Widths = List.filled(widget.numberOfSticks, 0);
    maxSection1Positions = List.filled(widget.numberOfSticks, 0);
    maxSection2Positions = List.filled(widget.numberOfSticks, 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDimensions();
  }

  void _updateDimensions() {
    for (int i = 0; i < widget.numberOfSticks; i++) {
      section1Widths[i] = widget.theme.ballSize * 5;
      section2Widths[i] = widget.theme.ballSize * 2;
      maxSection1Positions[i] =
          widget.theme.stickStart + section1Widths[i] - widget.theme.ballSize;
      maxSection2Positions[i] = widget.theme.stickStart +
          section1Widths[i] +
          section2Widths[i] -
          widget.theme.ballSize;
      _updateInitialBallPositions(i);
    }
  }

  void _updateInitialBallPositions(int stickIndex) {
    double spacing = widget.theme.ballSize;
    for (int i = 0; i < 4; i++) {
      stickSections[stickIndex][i].value =
          widget.theme.stickStart + (spacing * i);
    }
    stickSections[stickIndex][4].value =
        widget.theme.stickStart + section1Widths[stickIndex];
  }

  void _resetAllBalls() {
    for (int i = 0; i < widget.numberOfSticks; i++) {
      _updateInitialBallPositions(i);
    }
  }

  @override
  void dispose() {
    for (var stick in stickSections) {
      for (var notifier in stick) {
        notifier.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final currentTheme = brightness == Brightness.dark
        ? widget.theme.copyWith(
            ballColor: Colors.lightBlueAccent,
            verticalLineColor: Colors.white70,
          )
        : widget.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Sticks and Balls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAllBalls,
            tooltip: 'Reset All Balls',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(widget.numberOfSticks, (stickIndex) {
              return SizedBox(
                height: currentTheme.verticalSpacing,
                child: Stack(
                  children: [
                    _buildVerticalLine(
                        currentTheme.stickStart - currentTheme.lineWidth,
                        stickIndex,
                        currentTheme),
                    _buildVerticalLine(
                        currentTheme.stickStart + section1Widths[stickIndex],
                        stickIndex,
                        currentTheme),
                    _buildVerticalLine(
                      currentTheme.stickStart +
                          section1Widths[stickIndex] +
                          section2Widths[stickIndex],
                      stickIndex,
                      currentTheme,
                    ),
                    _buildHorizontalLine(currentTheme.stickStart,
                        section1Widths[stickIndex], stickIndex, currentTheme),
                    _buildHorizontalLine(
                      currentTheme.stickStart + section1Widths[stickIndex],
                      section2Widths[stickIndex],
                      stickIndex,
                      currentTheme,
                    ),
                    ...List.generate(
                      4,
                      (index) => _buildDraggableBall(
                          currentTheme, stickIndex, index, true),
                    ).reversed,
                    _buildDraggableBall(currentTheme, stickIndex, 4, false),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLine(double left, int stickIndex, StickTheme theme) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: theme.lineWidth,
        height: theme.lineHeight,
        color: theme.verticalLineColor,
      ),
    );
  }

  Widget _buildHorizontalLine(
      double left, double width, int stickIndex, StickTheme theme) {
    return Positioned(
      left: left,
      top: 20,
      child: Container(
        width: width,
        height: theme.lineWidth,
        color: theme.horizontalLineColor,
      ),
    );
  }

  Widget _buildDraggableBall(
      StickTheme theme, int stickIndex, int ballIndex, bool isSection1) {
    return ValueListenableBuilder<double>(
      valueListenable: stickSections[stickIndex][ballIndex],
      builder: (context, pos, child) {
        return Positioned(
          left: pos,
          top: 10,
          child: GestureDetector(
            onPanUpdate: (details) => _handleBallMovement(
                stickIndex, ballIndex, details.delta.dx, isSection1),
            child: Container(
              width: theme.ballSize,
              height: theme.ballSize,
              decoration: BoxDecoration(
                color: theme.ballColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.ballShadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBallMovement(
      int stickIndex, int ballIndex, double delta, bool isSection1) {
    List<ValueNotifier<double>> balls = stickSections[stickIndex];
    double minPosition = isSection1
        ? widget.theme.stickStart
        : widget.theme.stickStart + section1Widths[stickIndex];
    double maxPosition = isSection1
        ? maxSection1Positions[stickIndex]
        : maxSection2Positions[stickIndex];

    double newPosition = balls[ballIndex].value + delta;
    newPosition = newPosition.clamp(minPosition, maxPosition);

    List<double> positions = balls.map((n) => n.value).toList();
    positions[ballIndex] = newPosition;

    if (delta > 0) {
      for (int i = ballIndex;
          i < (isSection1 ? 4 : positions.length) - 1;
          i++) {
        if (positions[i + 1] - positions[i] < widget.theme.ballSize) {
          positions[i + 1] = positions[i] + widget.theme.ballSize;

          if (positions[i + 1] > maxPosition) {
            double excess = positions[i + 1] - maxPosition;
            for (int j = i + 1; j >= ballIndex; j--) {
              positions[j] -= excess;
            }
          }
        }
      }
    } else {
      for (int i = ballIndex; i > (isSection1 ? 0 : 4); i--) {
        if (positions[i] - positions[i - 1] < widget.theme.ballSize) {
          positions[i - 1] = positions[i] - widget.theme.ballSize;

          if (positions[i - 1] < minPosition) {
            double excess = minPosition - positions[i - 1];
            for (int j = i - 1; j <= ballIndex; j++) {
              positions[j] += excess;
            }
          }
        }
      }
    }

    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != balls[i].value) {
        balls[i].value = positions[i];
      }
    }
  }
}
