// import 'package:flutter/material.dart';

// class MultipleSticks extends StatefulWidget {
//   MultipleSticks({
//     super.key,
//   });

//   @override
//   _MultipleSticksState createState() => _MultipleSticksState();
// }

// class _MultipleSticksState extends State<MultipleSticks> {
//   static const int numberOfSticks = 17;
//   late double ballSize;
//   late double stickStart;
//   late double lineWidth;
//   late double lineHeight;
//   late double verticalSpacing;
//   late double totalWidth; // Added to track total width

//   late List<List<ValueNotifier<double>>> stickSections;
//   late List<double> section1Widths;
//   late List<double> section2Widths;
//   late List<double> maxSection1Positions;
//   late List<double> maxSection2Positions;

//   @override
//   void initState() {
//     super.initState();
//     _initializeValues();
//   }

//   void _initializeValues() {
//     stickSections = List.generate(numberOfSticks, (stickIndex) {
//       return [
//         ...List.generate(4, (index) => ValueNotifier(0.0)),
//         ValueNotifier(0.0)
//       ];
//     });
//     section1Widths = List.filled(numberOfSticks, 0);
//     section2Widths = List.filled(numberOfSticks, 0);
//     maxSection1Positions = List.filled(numberOfSticks, 0);
//     maxSection2Positions = List.filled(numberOfSticks, 0);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _updateResponsiveValues();
//     _updateDimensions();
//   }

//   void _updateResponsiveValues() {
//     final screenSize = MediaQuery.of(context).size;
//     final safeAreaPadding = MediaQuery.of(context).padding;

//     ballSize = screenSize.height * 0.033;
//     lineHeight = screenSize.height * 0.055;
//     verticalSpacing = screenSize.height * 0.055;
//     stickStart = 10;
//     lineWidth = screenSize.width * 0.005 > 8 ? 8 : screenSize.width * 0.005;
//   }

//   void _updateDimensions() {
//     for (int i = 0; i < numberOfSticks; i++) {
//       section1Widths[i] = ballSize * 5;
//       section2Widths[i] = ballSize * 2;
//       maxSection1Positions[i] = stickStart + section1Widths[i] - ballSize;
//       maxSection2Positions[i] =
//           stickStart + section1Widths[i] + section2Widths[i] - ballSize;
//       _updateInitialBallPositions(i);
//     }

//     // Calculate total width: stickStart + section1Width + section2Width + extra space for the last vertical line
//     totalWidth = stickStart +
//         section1Widths[0] +
//         section2Widths[0] +
//         lineWidth +
//         20; // Added 20 for padding
//   }

//   void _updateInitialBallPositions(int stickIndex) {
//     double spacing1 = ballSize;
//     for (int i = 0; i < 4; i++) {
//       stickSections[stickIndex][i].value = stickStart + (spacing1 * i);
//     }
//     stickSections[stickIndex][4].value =
//         stickStart + section1Widths[stickIndex];
//   }

//   void _resetAllBalls() {
//     for (int i = 0; i < numberOfSticks; i++) {
//       _updateInitialBallPositions(i);
//     }
//   }

//   @override
//   void dispose() {
//     for (var stick in stickSections) {
//       for (var notifier in stick) {
//         notifier.dispose();
//       }
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: _resetAllBalls,
//         child: const Icon(Icons.refresh),
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: SizedBox(
//                     width: totalWidth, // Using calculated total width
//                     child: Card(
//                       borderOnForeground: true,
//                       elevation: 10,
//                       shape: Border(
//                         top: BorderSide(
//                           color: Colors.black,
//                           width: lineWidth,
//                         ),
//                         bottom: BorderSide(
//                           color: Colors.black,
//                           width: lineWidth,
//                         ),
//                       ),
//                       child: Center(
//                         child: Column(
//                           children: List.generate(numberOfSticks, (stickIndex) {
//                             return SizedBox(
//                               height: verticalSpacing,
//                               child: Stack(
//                                 children: [
//                                   _buildVerticalLine(
//                                       stickStart - lineWidth, stickIndex),
//                                   _buildVerticalLine(
//                                       stickStart + section1Widths[stickIndex],
//                                       stickIndex),
//                                   _buildVerticalLine(
//                                       stickStart +
//                                           section1Widths[stickIndex] +
//                                           section2Widths[stickIndex],
//                                       stickIndex),
//                                   _buildHorizontalLine(stickStart,
//                                       section1Widths[stickIndex], stickIndex),
//                                   _buildHorizontalLine(
//                                       stickStart + section1Widths[stickIndex],
//                                       section2Widths[stickIndex],
//                                       stickIndex),
//                                   ...List.generate(
//                                     4,
//                                     (index) => _buildDraggableBall(
//                                       Colors.blue,
//                                       stickIndex,
//                                       index,
//                                       true,
//                                     ),
//                                   ).reversed,
//                                   _buildDraggableBall(
//                                     Colors.blue,
//                                     stickIndex,
//                                     4,
//                                     false,
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildVerticalLine(double left, int stickIndex) {
//     return Positioned(
//       left: left,
//       top: 0,
//       child: Container(
//         width: lineWidth,
//         height: lineHeight,
//         color: Colors.black,
//       ),
//     );
//   }

//   Widget _buildHorizontalLine(double left, double width, int stickIndex) {
//     return Positioned(
//       left: left,
//       top: lineHeight * 0.4,
//       child: Container(
//         width: width,
//         height: lineWidth,
//         color: Colors.brown,
//       ),
//     );
//   }

//   Widget _buildDraggableBall(
//       Color color, int stickIndex, int ballIndex, bool isSection1) {
//     return ValueListenableBuilder<double>(
//       valueListenable: stickSections[stickIndex][ballIndex],
//       builder: (context, pos, child) {
//         return Positioned(
//           left: pos,
//           top: lineHeight * 0.2,
//           child: GestureDetector(
//             onPanUpdate: (details) => _handleBallMovement(
//               stickIndex,
//               ballIndex,
//               details.delta.dx,
//               isSection1,
//             ),
//             child: Container(
//               width: ballSize,
//               height: ballSize,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                   colors: [Colors.black, Colors.red],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 6,
//                     offset: const Offset(2, 2),
//                   ),
//                   BoxShadow(
//                     color: Colors.white.withOpacity(0.7),
//                     blurRadius: 6,
//                     offset: const Offset(-2, -2),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _handleBallMovement(
//       int stickIndex, int ballIndex, double delta, bool isSection1) {
//     List<ValueNotifier<double>> balls = stickSections[stickIndex];
//     double minPosition =
//         isSection1 ? stickStart : stickStart + section1Widths[stickIndex];
//     double maxPosition = isSection1
//         ? maxSection1Positions[stickIndex]
//         : maxSection2Positions[stickIndex];

//     double newPosition = balls[ballIndex].value + delta;
//     newPosition = newPosition.clamp(minPosition, maxPosition);

//     List<double> positions = balls.map((n) => n.value).toList();
//     positions[ballIndex] = newPosition;

//     if (delta > 0) {
//       for (int i = ballIndex;
//           i < (isSection1 ? 4 : positions.length) - 1;
//           i++) {
//         if (positions[i + 1] - positions[i] < ballSize) {
//           positions[i + 1] = positions[i] + ballSize;

//           if (positions[i + 1] > maxPosition) {
//             double excess = positions[i + 1] - maxPosition;
//             for (int j = i + 1; j >= ballIndex; j--) {
//               positions[j] -= excess;
//             }
//           }
//         }
//       }
//     } else {
//       for (int i = ballIndex; i > (isSection1 ? 0 : 4); i--) {
//         if (positions[i] - positions[i - 1] < ballSize) {
//           positions[i - 1] = positions[i] - ballSize;

//           if (positions[i - 1] < minPosition) {
//             double excess = minPosition - positions[i - 1];
//             for (int j = i - 1; j <= ballIndex; j++) {
//               positions[j] += excess;
//             }
//           }
//         }
//       }
//     }

//     for (int i = 0; i < positions.length; i++) {
//       if (positions[i] != balls[i].value) {
//         balls[i].value = positions[i];
//       }
//     }
//   }
// }