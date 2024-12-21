import 'package:flutter/material.dart';

class HorMultipleSticks extends StatefulWidget {
  const HorMultipleSticks({
    super.key,
  });

  @override
  _HorMultipleSticksState createState() => _HorMultipleSticksState();
}

class _HorMultipleSticksState extends State<HorMultipleSticks> {
  static const int numberOfSticks = 17;
  bool isDarkMode = true; // Add theme state
  late double ballSize;
  late double stickStart;
  late double lineWidth;
  late double lineHeight;
  late double horizontalSpacing;
  late double totalHeight;

  late List<List<ValueNotifier<double>>> stickSections;
  late List<double> section1Heights;
  late List<double> section2Heights;
  late List<double> maxSection1Positions;
  late List<double> maxSection2Positions;

  // Theme colors
  late Color backgroundColor;
  late Color stickColor;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _updateThemeColors();
  }

  void _updateThemeColors() {
    backgroundColor = isDarkMode ? Colors.black : Colors.white;
    stickColor = isDarkMode ? Colors.brown : Colors.brown.shade300;
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _updateThemeColors();
    });
  }

  void _initializeValues() {
    stickSections = List.generate(numberOfSticks, (stickIndex) {
      return [
        ...List.generate(4, (index) => ValueNotifier(0.0)),
        ValueNotifier(0.0)
      ];
    });
    section1Heights = List.filled(numberOfSticks, 0);
    section2Heights = List.filled(numberOfSticks, 0);
    maxSection1Positions = List.filled(numberOfSticks, 0);
    maxSection2Positions = List.filled(numberOfSticks, 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateResponsiveValues();
    _updateDimensions();
  }

  void _updateResponsiveValues() {
    final screenSize = MediaQuery.of(context).size;
    final safeAreaPadding = MediaQuery.of(context).padding;

    ballSize = screenSize.width * 0.033;
    lineHeight = screenSize.width * 0.055;
    horizontalSpacing = screenSize.width * 0.055;
    stickStart = 10;
    lineWidth = screenSize.width * 0.005 > 8 ? 8 : screenSize.height * 0.005;
  }

  void _updateDimensions() {
    for (int i = 0; i < numberOfSticks; i++) {
      section1Heights[i] = ballSize * 5;
      section2Heights[i] = ballSize * 2;
      maxSection1Positions[i] = stickStart + section1Heights[i] - ballSize;
      maxSection2Positions[i] =
          stickStart + section1Heights[i] + section2Heights[i] - ballSize;
      _updateInitialBallPositions(i);
    }

    totalHeight =
        stickStart + section1Heights[0] + section2Heights[0] + lineWidth + 20;
  }

  void _updateInitialBallPositions(int stickIndex) {
    double spacing1 = ballSize;
    for (int i = 0; i < 4; i++) {
      stickSections[stickIndex][i].value = stickStart + (spacing1 * i);
    }
    stickSections[stickIndex][4].value =
        stickStart + section1Heights[stickIndex] + ballSize;
  }

  void _resetAllBalls() {
    for (int i = 0; i < numberOfSticks; i++) {
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
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _toggleTheme,
            child: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _resetAllBalls,
            child: const Column(
              children: [Icon(Icons.refresh), Text("RESET")],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: totalHeight,
                    child: Card(
                      color: backgroundColor,
                      borderOnForeground: true,
                      elevation: 0,
                      shape: Border(
                        left: BorderSide(
                          color: stickColor,
                          width: lineWidth,
                        ),
                        right: BorderSide(
                          color: stickColor,
                          width: lineWidth,
                        ),
                      ),
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Row(
                            children:
                                List.generate(numberOfSticks, (stickIndex) {
                              return SizedBox(
                                width: horizontalSpacing,
                                child: Stack(
                                  children: [
                                    _buildHorizontalLine(
                                        stickStart - lineWidth, stickIndex),
                                    _buildHorizontalLine(
                                        stickStart +
                                            section1Heights[stickIndex],
                                        stickIndex),
                                    _buildHorizontalLine(
                                        stickStart +
                                            section1Heights[stickIndex] +
                                            section2Heights[stickIndex],
                                        stickIndex),
                                    _buildVerticalLine(
                                        stickStart,
                                        section1Heights[stickIndex],
                                        stickIndex),
                                    _buildVerticalLine(
                                        stickStart +
                                            section1Heights[stickIndex],
                                        section2Heights[stickIndex],
                                        stickIndex),
                                    ...List.generate(
                                      4,
                                      (index) => _buildDraggableBall(
                                        !isDarkMode
                                            ? Colors.black
                                            : Color(0XFF800020),
                                        !isDarkMode
                                            ? const Color(0XFF1da1f2)
                                            : Color(0XFFAD343E),
                                        !isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                        stickIndex,
                                        index,
                                        true,
                                      ),
                                    ).reversed,
                                    _buildDraggableBall(
                                      !isDarkMode
                                          ? Colors.black
                                          : Color(
                                              0XFFD4AF37,
                                            ),
                                      !isDarkMode
                                          ? const Color(0XFFbd081c)
                                          : Color(
                                              0XFFD4AF37,
                                            ),
                                      !isDarkMode ? Colors.black : Colors.white,
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
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalLine(double top, int stickIndex) {
    return Positioned(
      top: top,
      left: 0,
      child: Container(
        height: lineWidth,
        width: lineHeight,
        color: stickColor,
      ),
    );
  }

  Widget _buildVerticalLine(double top, double height, int stickIndex) {
    return Positioned(
      top: top,
      left: lineHeight * 0.4,
      child: Container(
        height: height,
        width: lineWidth,
        color: stickColor,
      ),
    );
  }

  Widget _buildDraggableBall(Color color, Color shades1, Color shades2,
      int stickIndex, int ballIndex, bool isSection1) {
    return ValueListenableBuilder<double>(
      valueListenable: stickSections[stickIndex][ballIndex],
      builder: (context, pos, child) {
        return Positioned(
          top: pos,
          left: lineHeight * 0.2,
          child: GestureDetector(
            onPanUpdate: (details) => _handleBallMovement(
              stickIndex,
              ballIndex,
              details.delta.dy,
              isSection1,
            ),
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.5),
                  radius: 0.9,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    color.withOpacity(0.9),
                    color.withOpacity(1.0),
                    shades1,
                    shades2.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(2, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: -5,
                    offset: const Offset(-3, -3),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: const Alignment(-0.5, -0.5),
                    end: const Alignment(0.8, 0.8),
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
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
        isSection1 ? stickStart : stickStart + section1Heights[stickIndex];
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
