import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'multiple_sticks_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abacus Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.black,
          onSurface: const Color.fromARGB(255, 229, 213, 73),
          shadow: Colors.black87,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MultipleSticks(),
    );
  }
}
