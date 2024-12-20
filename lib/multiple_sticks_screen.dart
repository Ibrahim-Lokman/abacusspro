import 'package:flutter/material.dart';

class MultipleSticks extends StatefulWidget {
  final int numberOfSticks;
  final double ballSize;
  final double stickStart;
  final double lineWidth;
  final double lineHeight;
  final double verticalSpacing;

  const MultipleSticks({
    super.key,
    this.numberOfSticks = 17,
    this.ballSize = 25.0,
    this.stickStart = 10.0,
    this.lineWidth = 4.0,
    this.lineHeight = 40.0,
    this.verticalSpacing = 40.0,
  });

  @override
  MultipleSticksState createState() => MultipleSticksState();
}

class MultipleSticksState extends State<MultipleSticks> {
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
      section1Widths[i] = widget.ballSize * 5;
      section2Widths[i] = widget.ballSize * 2;
      maxSection1Positions[i] =
          widget.stickStart + section1Widths[i] - widget.ballSize;
      maxSection2Positions[i] = widget.stickStart +
          section1Widths[i] +
          section2Widths[i] -
          widget.ballSize;
      _updateInitialBallPositions(i);
    }
  }

  void _updateInitialBallPositions(int stickIndex) {
    double spacing = widget.ballSize;
    for (int i = 0; i < 4; i++) {
      stickSections[stickIndex][i].value = widget.stickStart + (spacing * i);
    }
    stickSections[stickIndex][4].value =
        widget.stickStart + section1Widths[stickIndex];
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                height: widget.verticalSpacing,
                child: Stack(
                  children: [
                    _buildVerticalLine(
                      widget.stickStart - widget.lineWidth,
                      stickIndex,
                      colorScheme,
                    ),
                    _buildVerticalLine(
                      widget.stickStart + section1Widths[stickIndex],
                      stickIndex,
                      colorScheme,
                    ),
                    _buildVerticalLine(
                      widget.stickStart +
                          section1Widths[stickIndex] +
                          section2Widths[stickIndex],
                      stickIndex,
                      colorScheme,
                    ),
                    _buildHorizontalLine(
                      widget.stickStart,
                      section1Widths[stickIndex],
                      stickIndex,
                      colorScheme,
                    ),
                    _buildHorizontalLine(
                      widget.stickStart + section1Widths[stickIndex],
                      section2Widths[stickIndex],
                      stickIndex,
                      colorScheme,
                    ),
                    ...List.generate(
                      4,
                      (index) => _buildDraggableBall(
                        stickIndex,
                        index,
                        true,
                        colorScheme,
                      ),
                    ).reversed,
                    _buildDraggableBall(
                      stickIndex,
                      4,
                      false,
                      colorScheme,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLine(
      double left, int stickIndex, ColorScheme colorScheme) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: widget.lineWidth,
        height: widget.lineHeight,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildHorizontalLine(
      double left, double width, int stickIndex, ColorScheme colorScheme) {
    return Positioned(
      left: left,
      top: 20,
      child: Container(
        width: width,
        height: widget.lineWidth,
        color: colorScheme.primary.withOpacity(0.7),
      ),
    );
  }

  Widget _buildDraggableBall(
      int stickIndex, int ballIndex, bool isSection1, ColorScheme colorScheme) {
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
              width: widget.ballSize,
              height: widget.ballSize,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.3),
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
        ? widget.stickStart
        : widget.stickStart + section1Widths[stickIndex];
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
        if (positions[i + 1] - positions[i] < widget.ballSize) {
          positions[i + 1] = positions[i] + widget.ballSize;

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
        if (positions[i] - positions[i - 1] < widget.ballSize) {
          positions[i - 1] = positions[i] - widget.ballSize;

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
