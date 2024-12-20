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
  final double ballSize = 20;
  final double stickStart = 40;
  final double lineWidth = 4;
  final double lineHeight = 40;
  final double verticalSpacing = 70; // Space between sticks

  // List of sections for each stick
  late List<List<ValueNotifier<double>>> stickSections;
  late List<double> section1Widths;
  late List<double> section2Widths;
  late List<double> maxSection1Positions;
  late List<double> maxSection2Positions;

  @override
  void initState() {
    super.initState();
    // Initialize lists
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
    double screenWidth = MediaQuery.of(context).size.width;
    double totalAvailableWidth = screenWidth - (2 * stickStart);

    for (int i = 0; i < numberOfSticks; i++) {
      section1Widths[i] = totalAvailableWidth * 0.6;
      section2Widths[i] = totalAvailableWidth * 0.4;
      maxSection1Positions[i] = stickStart + section1Widths[i] - ballSize;
      maxSection2Positions[i] =
          stickStart + section1Widths[i] + section2Widths[i] - ballSize;
      _updateInitialBallPositions(i);
    }
  }

  void _updateInitialBallPositions(int stickIndex) {
    // Update section 1 balls (first 4 balls)
    double spacing1 = section1Widths[stickIndex] / 5;
    for (int i = 0; i < 4; i++) {
      stickSections[stickIndex][i].value = stickStart + (spacing1 * (i + 1));
    }

    // Update section 2 ball (last ball)
    double spacing2 = section2Widths[stickIndex] / 2;
    stickSections[stickIndex][4].value =
        stickStart + section1Widths[stickIndex] + spacing2;
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
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(numberOfSticks, (stickIndex) {
            return SizedBox(
              height: verticalSpacing,
              child: Stack(
                children: [
                  // Vertical lines
                  _buildVerticalLine(stickStart - lineWidth, stickIndex),
                  _buildVerticalLine(
                      stickStart + section1Widths[stickIndex], stickIndex),
                  _buildVerticalLine(
                      stickStart +
                          section1Widths[stickIndex] +
                          section2Widths[stickIndex],
                      stickIndex),
                  // Horizontal lines
                  _buildHorizontalLine(
                      stickStart, section1Widths[stickIndex], stickIndex),
                  _buildHorizontalLine(stickStart + section1Widths[stickIndex],
                      section2Widths[stickIndex], stickIndex),
                  // Section 1 Balls (4 balls)
                  ...List.generate(
                    4,
                    (index) => _buildDraggableBall(
                      Colors.blue,
                      stickIndex,
                      index,
                      true,
                    ),
                  ).reversed,
                  // Section 2 Ball (1 ball)
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
        height: 10,
        color: Colors.black,
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
      // Moving right
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
      // Moving left
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

    // Update all positions
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != balls[i].value) {
        balls[i].value = positions[i];
      }
    }
  }
}
