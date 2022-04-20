import 'package:flutter/material.dart';
import 'package:text_in_image_detector/dialogs.dart';
import 'package:text_in_image_detector/text_detector.dart';

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
        primarySwatch: Colors.green,
      ),
      home: const TextDetectorWidget(dialogHandler: AppDialogs()),
    );
  }
}
