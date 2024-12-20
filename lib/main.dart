import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MultipleSticks(),
    );
  }
}

class MultipleSticks extends StatefulWidget {
  const MultipleSticks({super.key});

  @override
  _MultipleSticksState createState() => _MultipleSticksState();
}

class _MultipleSticksState extends State<MultipleSticks> {
  static const int numberOfSticks = 17;
  final double ballSize = 25;
  final double stickStart = 10;
  final double lineWidth = 4;
  final double lineHeight = 40;
  final double verticalSpacing = 40;

  late List<List<ValueNotifier<double>>> stickSections;
  late List<double> section1Widths;
  late List<double> section2Widths;
  late List<double> maxSection1Positions;
  late List<double> maxSection2Positions;

  @override
  void initState() {
    super.initState();
    stickSections = List.generate(numberOfSticks, (stickIndex) {
      return [
        ...List.generate(4, (index) => ValueNotifier(0.0)),
        ValueNotifier(0.0)
      ];
    });
    section1Widths = List.filled(numberOfSticks, 0);
    section2Widths = List.filled(numberOfSticks, 0);
    maxSection1Positions = List.filled(numberOfSticks, 0);
    maxSection2Positions = List.filled(numberOfSticks, 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDimensions();
  }

  void _updateDimensions() {
    // Set fixed widths based on ball size
    for (int i = 0; i < numberOfSticks; i++) {
      // Section 1 width = ballSize * 5 (space for 4 balls with gaps)
      section1Widths[i] = ballSize * 5;
      // Section 2 width = ballSize * 2 (space for 1 ball with gaps)
      section2Widths[i] = ballSize * 2;

      // Update maximum positions for balls
      maxSection1Positions[i] = stickStart + section1Widths[i] - ballSize;
      maxSection2Positions[i] =
          stickStart + section1Widths[i] + section2Widths[i] - ballSize;

      _updateInitialBallPositions(i);
    }
  }

  void _updateInitialBallPositions(int stickIndex) {
    // Update section 1 balls (first 4 balls)
    double spacing1 =
        ballSize; // Each ball takes up one ball size worth of space
    for (int i = 0; i < 4; i++) {
      stickSections[stickIndex][i].value = stickStart + (spacing1 * (i + 1));
    }

    // Update section 2 ball (last ball)
    stickSections[stickIndex][4].value =
        stickStart + section1Widths[stickIndex] + ballSize;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Sticks and Balls'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(numberOfSticks, (stickIndex) {
              return SizedBox(
                height: verticalSpacing,
                child: Stack(
                  children: [
                    _buildVerticalLine(stickStart - lineWidth, stickIndex),
                    _buildVerticalLine(
                        stickStart + section1Widths[stickIndex], stickIndex),
                    _buildVerticalLine(
                        stickStart +
                            section1Widths[stickIndex] +
                            section2Widths[stickIndex],
                        stickIndex),
                    _buildHorizontalLine(
                        stickStart, section1Widths[stickIndex], stickIndex),
                    _buildHorizontalLine(
                        stickStart + section1Widths[stickIndex],
                        section2Widths[stickIndex],
                        stickIndex),
                    ...List.generate(
                      4,
                      (index) => _buildDraggableBall(
                        Colors.blue,
                        stickIndex,
                        index,
                        true,
                      ),
                    ).reversed,
                    _buildDraggableBall(
                      Colors.blue,
                      stickIndex,
                      4,
                      false,
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

  Widget _buildVerticalLine(double left, int stickIndex) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: lineWidth,
        height: lineHeight,
        color: Colors.black,
      ),
    );
  }

  Widget _buildHorizontalLine(double left, double width, int stickIndex) {
    return Positioned(
      left: left,
      top: 20,
      child: Container(
        width: width,
        height: 5,
        color: Colors.brown,
      ),
    );
  }

  Widget _buildDraggableBall(
    Color color,
    int stickIndex,
    int ballIndex,
    bool isSection1,
  ) {
    return ValueListenableBuilder<double>(
      valueListenable: stickSections[stickIndex][ballIndex],
      builder: (context, pos, child) {
        return Positioned(
          left: pos,
          top: 10,
          child: GestureDetector(
            onPanUpdate: (details) => _handleBallMovement(
              stickIndex,
              ballIndex,
              details.delta.dx,
              isSection1,
            ),
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
    double minPosition =
        isSection1 ? stickStart : stickStart + section1Widths[stickIndex];
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
        if (positions[i + 1] - positions[i] < ballSize) {
          positions[i + 1] = positions[i] + ballSize;

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
        if (positions[i] - positions[i - 1] < ballSize) {
          positions[i - 1] = positions[i] - ballSize;

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
