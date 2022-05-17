import 'package:flutter/material.dart';
import 'package:text_in_image_detector/dialogs.dart';
import 'package:text_in_image_detector/state/text_detector_controller.dart';
import 'package:text_in_image_detector/state/text_detector_widget.dart';

/// Main entry point - just starts below [App] widget
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TextDetectorController controller;

  @override
  void initState() {
    super.initState();
    controller = TextDetectorController(
      dialogHandler: const AppDialogs(),
    );
  }

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
        textScannerController: controller..startScan(),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await controller.dispose();
    super.dispose();
  }
}
