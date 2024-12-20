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
  // Initial positions of the balls
  final List<ValueNotifier<double>> ballPositions = [
    ValueNotifier(100.0),
    ValueNotifier(200.0),
    ValueNotifier(300.0)
  ];

  final double ballSize = 30;
  final double stickStart = 40;
  final double stickPadding = 40;
  final double lineWidth = 4;
  final double lineHeight = 40;
  late final double maxPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    maxPosition =
        MediaQuery.of(context).size.width - stickPadding - ballSize - lineWidth;
  }

  @override
  void dispose() {
    for (var notifier in ballPositions) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double stickWidth = MediaQuery.of(context).size.width - (2 * stickPadding);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stick and Balls'),
      ),
      body: Stack(
        children: [
          // Start Line
          Positioned(
            left: stickStart - lineWidth,
            top: 280,
            child: Container(
              width: lineWidth,
              height: lineHeight,
              color: Colors.black,
            ),
          ),
          // End Line
          Positioned(
            left: stickStart + stickWidth,
            top: 280,
            child: Container(
              width: lineWidth,
              height: lineHeight,
              color: Colors.black,
            ),
          ),
          // Stick
          Positioned(
            left: stickStart,
            top: 300,
            child: Container(
              width: stickWidth,
              height: 10,
              color: Colors.black,
            ),
          ),
          // Balls
          ...List.generate(
              3,
              (index) => _buildDraggableBall(
                    [Colors.red, Colors.green, Colors.blue][index],
                    index,
                  )).reversed,
        ],
      ),
    );
  }

  Widget _buildDraggableBall(Color color, int index) {
    return ValueListenableBuilder<double>(
      valueListenable: ballPositions[index],
      builder: (context, position, child) {
        return Positioned(
          left: position,
          top: 290,
          child: GestureDetector(
            onPanUpdate: (details) =>
                _handleBallMovement(index, details.delta.dx),
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

  void _handleBallMovement(int ballIndex, double delta) {
    double newPosition = ballPositions[ballIndex].value + delta;

    // Clamp to bounds
    newPosition = newPosition.clamp(stickStart, maxPosition);

    List<double> positions = ballPositions.map((n) => n.value).toList();
    positions[ballIndex] = newPosition;

    if (delta > 0) {
      // Moving right - only check collisions with balls to the right
      for (int i = ballIndex; i < positions.length - 1; i++) {
        if (positions[i + 1] - positions[i] < ballSize) {
          double overlap = ballSize - (positions[i + 1] - positions[i]);
          positions[i + 1] = positions[i] + ballSize;

          // If rightmost ball would exceed bounds, push back only the affected balls
          if (positions[i + 1] > maxPosition) {
            double excess = positions[i + 1] - maxPosition;
            for (int j = i + 1; j >= ballIndex; j--) {
              positions[j] -= excess;
            }
          }
        }
      }
    } else {
      // Moving left - only check collisions with balls to the left
      for (int i = ballIndex; i > 0; i--) {
        if (positions[i] - positions[i - 1] < ballSize) {
          double overlap = ballSize - (positions[i] - positions[i - 1]);
          positions[i - 1] = positions[i] - ballSize;

          // If leftmost ball would exceed bounds, push back only the affected balls
          if (positions[i - 1] < stickStart) {
            double excess = stickStart - positions[i - 1];
            for (int j = i - 1; j <= ballIndex; j++) {
              positions[j] += excess;
            }
          }
        }
      }
    }

    // Update all positions
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != ballPositions[i].value) {
        ballPositions[i].value = positions[i];
      }
    }
  }
}
