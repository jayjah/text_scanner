// ignore_for_file: curly_braces_in_flow_control_structures, unawaited_futures

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_in_image_detector/dialogs.dart' show AppDialogs;

extension _Translation on String {
  TranslateLanguage get translationLanguage {
    switch (this) {
      case 'fr':
        return TranslateLanguage.french;
      case 'gr':
        return TranslateLanguage.greek;
      case 'it':
        return TranslateLanguage.italian;
      case 'pt':
        return TranslateLanguage.portuguese;
      case 'es':
        return TranslateLanguage.spanish;
      case 'de':
        return TranslateLanguage.german;
      default:
        return TranslateLanguage.english;
    }
  }
}

/// Widget does the following things:
///   1. Get an image from gallery OR camera. The decision is based on a dialog.
///       Afterwards another dialog is shown, where the user can enter the language identifier.
///       This language identifier should represent the language, which is visible in the text in the image.
///   2. Extract any text from the image
///   3. Translate the extracted text to an other language. Currently this is hard coded to `en`
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
  late final TextEditingController textController;
  late final TextRecognizer textRecognizer;
  // internal widget state variables
  bool _loading = true;
  bool _translating = false;
  String? textInImage;
  String? translatedText;
  String? languageIdentifier;

  @override
  void initState() {
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    textController = TextEditingController();
    _initStuff();

    super.initState();
  }

  void _initStuff({bool setNewState = false}) {
    // (re)set state to initial state
    _loading = true;
    _translating = false;
    textInImage = null;
    translatedText = null;
    languageIdentifier = null;
    textController.text = 'fr';
    if (setNewState) setState(() {});

    // ensure it gets called on next frame
    Future<void>.microtask(() async {
      // get image source from dialog
      final ImageSource imageSource = (await widget.dialogHandler.showDialog(
              'Pick image',
              'Do you want to pick an image from gallery?\nDefault is going to pick an image from camera.'))
          ? ImageSource.gallery
          : ImageSource.camera;

      // get language identifier code from dialog, e.G. fr for french
      //  this identifier code indicates language, which should be actually the language from the text in the image itself
      languageIdentifier = await widget.dialogHandler.languageCode(
        'Language',
        'Which language should be translated from?\nImportant: Just specify language identifier, e.G. English=en, french=fr, italian=it, espanol=es, portuguese=pt etc.',
        textController,
      );

      // 1. pick an image
      // 2. parse text from given image
      // 3. translate that text
      pickImage(imageSource).then(parseTextFromImage).whenComplete(() =>
          translateText(
              fromLanguage: languageIdentifier!.translationLanguage,
              toLanguage: TranslateLanguage.english));
    });
  }

  @override
  Widget build(BuildContext context) {
    // default spacer widget
    const Widget spacer = SizedBox(
      height: 55,
    );
    // default helper|error text style
    const TextStyle helperOrErrorStyle = TextStyle(
      fontSize: 16,
    );

    // build child widget from internal state
    late final Widget child;
    if (_loading)
      child = const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    else if (_translating)
      child = const Center(
        child: Text(
          'Please wait, text is being translated...',
          style: helperOrErrorStyle,
        ),
      );
    else /* show text from the image and the translated text, if available */
      child = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: <Widget>[
            spacer,
            _closeButton,
            spacer,
            if (textInImage?.isNotEmpty == true) ...<Widget>[
              const Text(
                'Text to translate:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              Center(child: Text(textInImage!)),
            ] else
              const Text(
                'ERROR - No translated text were found',
                style: helperOrErrorStyle,
              ),
            spacer,
            if (translatedText?.isNotEmpty == true) ...<Widget>[
              const Text(
                'Translated text:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              Center(child: Text(translatedText!))
            ] else
              const Text(
                'ERROR - Could not translate text',
                style: helperOrErrorStyle,
              ),
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

  /// Parse text from given [value] and saves it into [textInImage]
  ///   Internal widget state gets updated afterwards
  Future<void> parseTextFromImage(XFile? value) async {
    if (value == null) return;

    // init google ml kit with text detector
    try {
      final RecognizedText recognizedText = await textRecognizer
          .processImage(InputImage.fromFilePath(value.path));
      textInImage = recognizedText.text;
    } catch (_) {
      debugPrint('ERROR while processing image: $_');
    }

    // get detected language
    // Currently just make it available via a dialog - an alternative would be the following:
    // await GoogleMlKit.nlp.languageIdentifier().identifyLanguage(textInImage!);

    // update widget state
    _loading = false;
    _translating = true;
    if (mounted) setState(() {});

    //translateText(fromLanguage: languageIdentifier!, toLanguage: 'en');
  }

  /// Translates text from [textInImage] and saves the translated text text into [translatedText]
  ///   Internal widget state gets updated afterwards
  Future<void> translateText(
      {required TranslateLanguage toLanguage,
      required TranslateLanguage fromLanguage}) async {
    // just print some stuff in debug mode
    debugPrint('Text in image: $textInImage');
    debugPrint('ToLanguage: $toLanguage; fromLanguage: $fromLanguage');

    // ensure some text where found in the image, otherwise stop here
    if (textInImage == null) {
      _translating = false;
      if (mounted) setState(() {});
      return;
    }

    // translate text with google ml kit
    final OnDeviceTranslator mlTranslator = OnDeviceTranslator(
      sourceLanguage: fromLanguage,
      targetLanguage: toLanguage,
    );
    try {
      translatedText = await mlTranslator.translateText(textInImage!);
    } catch (_) {
      debugPrint('ERROR while translating text: $_');

      // use another translate mechanism to translate given text
      /*final Translator anotherTranslator =
          Translator(from: fromLanguage, to: toLanguage);
      translatedText = await anotherTranslator.translate(textInImage!);
      anotherTranslator.dispose();*/
    } finally {
      // mlTranslator.close();
    }

    // update state
    _translating = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    textRecognizer.close();
    textController.dispose();
    super.dispose();
  }
}
