import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StickAndBalls(),
    );
  }
}

class StickAndBalls extends StatefulWidget {
  const StickAndBalls({super.key});

  @override
  _StickAndBallsState createState() => _StickAndBallsState();
}

class _StickAndBallsState extends State<StickAndBalls> {
  // Two sections of balls: 4 balls and 1 ball
  final List<ValueNotifier<double>> section1Balls =
      List.generate(4, (index) => ValueNotifier(100.0 + (index * 50.0)));
  final List<ValueNotifier<double>> section2Balls = [ValueNotifier(400.0)];

  final double ballSize = 30;
  final double stickStart = 40;
  late double section1Width;
  late double section2Width;
  final double lineWidth = 4;
  final double lineHeight = 40;

  late final double maxSection1Position;
  late final double maxSection2Position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate section widths based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double totalAvailableWidth = screenWidth - (2 * stickStart);

    // Distribute available width between sections (60% for section1, 40% for section2)
    section1Width = totalAvailableWidth * 0.6;
    section2Width = totalAvailableWidth * 0.4;

    // Calculate maximum positions for each section
    maxSection1Position = stickStart + section1Width - ballSize;
    maxSection2Position = stickStart + section1Width + section2Width - ballSize;

    // Update initial ball positions if needed
    _updateInitialBallPositions();
  }

  void _updateInitialBallPositions() {
    // Update section 1 balls
    double spacing1 = section1Width / (section1Balls.length + 1);
    for (int i = 0; i < section1Balls.length; i++) {
      section1Balls[i].value = stickStart + (spacing1 * (i + 1));
    }

    // Update section 2 ball
    double spacing2 = section2Width / 2;
    section2Balls[0].value = stickStart + section1Width + spacing2;
  }

  @override
  void dispose() {
    for (var notifier in [...section1Balls, ...section2Balls]) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lines and Balls'),
      ),
      body: Stack(
        children: [
          // Line 1
          _buildVerticalLine(stickStart - lineWidth),
          // Line 2 (middle)
          _buildVerticalLine(stickStart + section1Width),
          // Line 3
          _buildVerticalLine(stickStart + section1Width + section2Width),
          // Horizontal lines
          _buildHorizontalLine(stickStart, section1Width),
          _buildHorizontalLine(stickStart + section1Width, section2Width),
          // Section 1 Balls (4 balls)
          ...List.generate(
              4,
              (index) => _buildDraggableBall(
                    Colors.blue,
                    index,
                    section1Balls[index],
                    true,
                  )).reversed,
          // Section 2 Ball (1 ball)
          _buildDraggableBall(
            Colors.blue,
            0,
            section2Balls[0],
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLine(double left) {
    return Positioned(
      left: left,
      top: 280,
      child: Container(
        width: lineWidth,
        height: lineHeight,
        color: Colors.black,
      ),
    );
  }

  Widget _buildHorizontalLine(double left, double width) {
    return Positioned(
      left: left,
      top: 300,
      child: Container(
        width: width,
        height: 10,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDraggableBall(
    Color color,
    int index,
    ValueNotifier<double> position,
    bool isSection1,
  ) {
    return ValueListenableBuilder<double>(
      valueListenable: position,
      builder: (context, pos, child) {
        return Positioned(
          left: pos,
          top: 290,
          child: GestureDetector(
            onPanUpdate: (details) => _handleBallMovement(
              index,
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

  void _handleBallMovement(int ballIndex, double delta, bool isSection1) {
    List<ValueNotifier<double>> balls =
        isSection1 ? section1Balls : section2Balls;
    double minPosition = isSection1 ? stickStart : stickStart + section1Width;
    double maxPosition = isSection1 ? maxSection1Position : maxSection2Position;

    double newPosition = balls[ballIndex].value + delta;
    newPosition = newPosition.clamp(minPosition, maxPosition);

    List<double> positions = balls.map((n) => n.value).toList();
    positions[ballIndex] = newPosition;

    if (delta > 0) {
      // Moving right
      for (int i = ballIndex; i < positions.length - 1; i++) {
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
      for (int i = ballIndex; i > 0; i--) {
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
