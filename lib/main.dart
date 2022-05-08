import 'package:flutter/material.dart';
import 'package:text_in_image_detector/dialogs.dart';
import 'package:text_in_image_detector/state/text_detector_controller.dart';
import 'package:text_in_image_detector/state/text_detector_widget.dart';

/// Main entry point - just starts below [App] widget
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Detector',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          primary: Colors.deepOrangeAccent,
        ),
        useMaterial3: true,
      ),
      home: TextDetectorWidget(
        textScannerController: TextDetectorController(
          dialogHandler: const AppDialogs(),
        )..startScan(),
      ),
    );
  }
}
