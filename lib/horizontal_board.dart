import 'package:flutter/material.dart';

class HorMultipleSticks extends StatefulWidget {
  const HorMultipleSticks({
    super.key,
  });

  @override
  _HorMultipleSticksState createState() => _HorMultipleSticksState();
}

class _HorMultipleSticksState extends State<HorMultipleSticks> {
  int numberOfSticks = 13; // Changed from static to instance variable
  bool isDarkMode = true;
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

  // Available stick count options
  // final List<int> stickOptions = [1, 3, 5, 7, 9, 11, 13, 15, 17];
  final List<int> stickOptions = [for (int i = 17; i >= 1; i -= 1) i];

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

  void _updateStickCount(int? newCount) {
    if (newCount != null) {
      setState(() {
        numberOfSticks = newCount;
        _initializeValues();
        _updateDimensions();
      });
    }
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

    ballSize = screenSize.width * 0.042;
    lineHeight = screenSize.width * 0.055;
    horizontalSpacing = screenSize.width * 0.055;
    stickStart = 10;
    lineWidth = screenSize.width * 0.0055 > 8 ? 8 : screenSize.width * 0.0055;
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.white,
            child: Image.asset(
              'assets/abacusmbaa.png',
              width: 250,
              height: 50,
              // fit: BoxFit.fitWidth,
            ),
          ),
          actions: [
            Card(
              color: isDarkMode ? Colors.white : Colors.black,
              child: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      value: 'Rods',
                      child: Card(
                        color: isDarkMode ? Colors.black : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Number of Rods: ',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: DropdownButton<int>(
                                  dropdownColor:
                                      isDarkMode ? Colors.black : Colors.white,
                                  isDense: true,
                                  padding: EdgeInsets.all(4),
                                  value: numberOfSticks,
                                  // dropdownColor: Colors.grey[800],
                                  style: TextStyle(
                                    // Use the appropriate text color based on theme
                                    color: Colors.black,
                                  ),
                                  items: stickOptions.map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        '$value',
                                        style: TextStyle(
                                            // Match the dropdown item text color with the button text color
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        duration: Durations.long4,
                                        dismissDirection:
                                            DismissDirection.horizontal,
                                        showCloseIcon: true,
                                        content:
                                            Text('$newValue rods selected'),
                                      ));

                                      // Make sure to call setState to update the UI
                                      setState(() {
                                        numberOfSticks = newValue;
                                      });
                                      // If _updateStickCount does additional work, call it here
                                      _updateStickCount(newValue);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      onTap: _toggleTheme,
                      value: 'theme',
                      child: Card(
                        color: isDarkMode ? Colors.black : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                  isDarkMode
                                      ? 'Enable Light Mode'
                                      : 'Enable Dark Mode',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                              SizedBox(width: 10),
                              Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ),
            Card(
              color: isDarkMode ? Colors.white : Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: _resetAllBalls,
                  child: Column(
                    children: [
                      Icon(Icons.refresh,
                          color: isDarkMode ? Colors.black : Colors.white),
                      Text(
                        "RESET",
                        style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: LayoutBuilder(builder: (context, constraints) {
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
                                      // Color(0XFF1877f2),
                                      // Color(0XFF1da1f2),
                                      // Color(0XFF0088cc),
                                      ...List.generate(
                                        4,
                                        (index) => _buildDraggableBall(
                                          // Change color for 4th bead (index 3) of 9th stick (stickIndex 8)
                                          (numberOfSticks >= 9 &&
                                                  stickIndex ==
                                                      numberOfSticks - 9 &&
                                                  index == 3)
                                              ? !isDarkMode
                                                  ? Color(0XFFff0000)
                                                  : Color.fromARGB(
                                                      255, 246, 190, 6)
                                              : (!isDarkMode
                                                  ? Colors.black87
                                                  : Color(0XFF1877f2)),

                                          (numberOfSticks >= 9 &&
                                                  stickIndex ==
                                                      numberOfSticks - 9 &&
                                                  index == 3)
                                              ? !isDarkMode
                                                  ? Color(0XFFff0000)
                                                  : Color.fromARGB(
                                                      255, 221, 221, 32)
                                              : (!isDarkMode
                                                  ? Colors.black
                                                  : Color(0XFF1da1f2)),
                                          !isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          stickIndex,
                                          index,
                                          true,
                                        ),
                                      ).reversed,

                                      // Color(0XFFff0000),
                                      // Color(0XFFbd081c),
                                      // Color(0XFFc32aa3),
                                      _buildDraggableBall(
                                        !isDarkMode
                                            ? const Color.fromARGB(
                                                255, 0, 100, 12)
                                            : Color(0XFFff0000),
                                        !isDarkMode
                                            ? const Color.fromARGB(
                                                255, 0, 60, 7)
                                            : Color(0XFFbd081c),
                                        !isDarkMode
                                            ? Colors.black
                                            : Colors.white,
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
            }),
          ),
        ));
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
      left: lineHeight * 0.45,
      child: Container(
        height: height,
        width: lineWidth * 0.45,
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
          left: lineWidth,
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
                    color.withOpacity(0.6),
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
                    spreadRadius: -6,
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
