// ignore_for_file: curly_braces_in_flow_control_structures, unawaited_futures

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learning_translate/learning_translate.dart';
import 'package:text_in_image_detector/dialogs.dart' show AppDialogs;

class TextDetectorWidget extends StatefulWidget {
  const TextDetectorWidget({
    Key? key,
    required this.dialogHandler,
  }) : super(key: key);
  final AppDialogs dialogHandler;
  @override
  _TextDetectorState createState() => _TextDetectorState();
}

class _TextDetectorState extends State<TextDetectorWidget> {
  bool loading = true;
  bool translating = false;
  String? textInImage;
  String? translatedText;
  String? languageIdentifier;
  @override
  void initState() {
    _initStuff();

    super.initState();
  }

  void _initStuff({bool setNewState = false}) {
    // reset state to initial state
    loading = true;
    translating = false;
    textInImage = null;
    translatedText = null;
    languageIdentifier = null;
    if (setNewState) setState(() {});

    // ensure it gets called on next frame
    Future<void>.microtask(() async {
      final ImageSource imageSource = (await widget.dialogHandler.showDialog(
              'Pick image', 'Do you want to pick an image from gallery?'))
          ? ImageSource.gallery
          : ImageSource.camera;

      languageIdentifier = await widget.dialogHandler.languageCode('Language',
          'Which language should be translated from?\nImportant: Just specify language identifier, e.G. English=en, french=fr, italian=it, espanol=es, portuguese=pt etc.');
      pickImage(imageSource).then(readTextFromImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    // default spacer widget
    const Widget spacer = SizedBox(
      height: 55,
    );

    late final Widget child;
    // build child widget from internal state
    if (loading)
      child = const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    else if (textInImage == null)
      child = Column(
        children: <Widget>[
          spacer,
          _closeButton,
          const Center(
            child: Text('No text in image detected'),
          ),
        ],
      );
    else if (translating)
      child = const Center(
        child: Text('Text is being translated...'),
      );
    else
      child = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: <Widget>[
            spacer,
            _closeButton,
            spacer,
            const Text(
              'Text to translate:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
            if (textInImage != null) Center(child: Text(textInImage!)),
            spacer,
            if (translatedText != null) ...<Widget>[
              const Text(
                'Translated text:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(translatedText!)
            ] else
              const Text('Could not translate text'),
            spacer,
          ],
        ),
      );

    return Material(
      child: child,
    );
  }

  // A default close button, which calls [_initStuff] internally
  Widget get _closeButton => Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          color: Colors.red,
          onPressed: () => _initStuff(setNewState: true),
          icon: const Icon(Icons.close),
        ),
      );

  /// Pick an image from given [source]
  Future<XFile?> pickImage(ImageSource source) {
    return ImagePicker().pickImage(source: source);
  }

  Future<void> readTextFromImage(XFile? value) async {
    if (value == null) return;

    // init google ml kit with text detector
    final TextDetector textRecognizer = GoogleMlKit.vision.textDetector();
    final RecognisedText recognizedText =
        await textRecognizer.processImage(InputImage.fromFilePath(value.path));
    textInImage = recognizedText.text;

    // get first detected language
    /*final String detectedLanguage = recognizedText.blocks
        .firstWhere(
            (TextBlock element) => element.recognizedLanguages.first.isNotEmpty)
        .recognizedLanguages
        .first;*/
    // an alternative may be:
    // await GoogleMlKit.nlp.languageIdentifier().identifyLanguage(textInImage!);
    // Currently just make it available via a dialog

    // set specific new state variables
    loading = false;
    translating = true;
    if (mounted) setState(() {});

    textRecognizer.close();
    translateText(fromLanguage: languageIdentifier!, toLanguage: 'en');
  }

  Future<void> translateText(
      {required String toLanguage, required String fromLanguage}) async {
    // just print some stuff in debug mode
    if (kDebugMode) {
      print('ToLanguage: $toLanguage; fromLanguage: $fromLanguage');
    }

    // ensure some text where found in the image, otherwise stop here
    if (textInImage == null) {
      translating = false;
      if (mounted) setState(() {});
      return;
    }

    // translate text with google ml kit
    final OnDeviceTranslator translator = GoogleMlKit.nlp.onDeviceTranslator(
        sourceLanguage: fromLanguage, targetLanguage: toLanguage);
    try {
      translatedText = await translator.translateText(textInImage!);
    } catch (e) {
      final Translator translator =
          Translator(from: fromLanguage, to: toLanguage);
      translatedText = await translator.translate(textInImage!);
      translator.dispose();
    }

    // update state
    translating = false;
    if (mounted) setState(() {});

    translator.close();
  }
}
