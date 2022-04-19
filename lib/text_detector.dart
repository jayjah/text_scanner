// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

class TextDetector extends StatefulWidget {
  const TextDetector({Key? key}) : super(key: key);

  @override
  _TextDetectorState createState() => _TextDetectorState();
}

class _TextDetectorState extends State<TextDetector> {
  final List<String> textInImage = <String>[];
  bool loading = true;
  bool translating = false;

  String? translatedText;

  @override
  void initState() {
    // TODO(jayjah): make the choise of image source available via dialog
    pickImage(ImageSource.camera).then(readTextFromImage);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late final Widget child;

    if (loading)
      child = const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    else if (textInImage.isEmpty)
      child = const Center(
        child: Text('No text in images detected'),
      );
    else if (translating)
      child = const Center(
        child: Text('Text is being translated...'),
      );
    else {
      const Widget spacer = SizedBox(
        height: 55,
      );

      child = SingleChildScrollView(
        child: Column(
          children: [
            spacer,
            const Text('Text to translate:'),
            for (final content in textInImage) Center(child: Text(content)),
            spacer,
            if (translatedText != null) ...[
              const Text('Translated text:'),
              Text(translatedText!)
            ] else
              const Text('Could not translate text'),
            spacer,
          ],
        ),
      );
    }

    return Material(
      child: child,
    );
  }

  Future<XFile?> pickImage(ImageSource source) {
    return ImagePicker().pickImage(source: source);
  }

  Future<void> readTextFromImage(XFile? value) async {
    if (value == null) return;

    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFile(File(value.path));
    final TextRecognizer textRecognizer =
        GoogleVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    for (TextBlock block in visionText.blocks) {
      final String? text = block.text;
      if (text != null) textInImage.add(text);
    }

    if (mounted)
      setState(() {
        loading = false;
        translating = true;
      });
    translateText('en');
  }

  Future<void> translateText(String toLanguage) async {
    if (textInImage.isEmpty) {
      translating = false;
      if (mounted) setState(() {});
      return;
    }

    String textToTranslate = '';
    for (final toTranslate in textInImage) {
      textToTranslate += toTranslate;
    }

    final translation =
        await GoogleTranslator().translate(textToTranslate, to: toLanguage);
    translatedText = translation.text;
    translating = false;
    if (mounted) setState(() {});
  }
}
