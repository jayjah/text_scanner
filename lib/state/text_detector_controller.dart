import 'package:flutter/material.dart' show ChangeNotifier, debugPrint;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_in_image_detector/dialogs.dart' show AppDialogs;

class TextDetectorController with ChangeNotifier {
  TextDetectorController({
    required this.dialogHandler,
  });
  final AppDialogs dialogHandler;
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  OnDeviceTranslator? _mlTranslator;

  // internal state variables
  bool _loading = true;
  bool _translating = false;
  String? _textInImage;
  String? _translatedText;
  TranslateLanguage? _languageIdentifier;

  bool get isLoading => _loading;
  bool get isTranslating => _translating;
  String? get textFromImage => _textInImage;
  String? get translatedText => _translatedText;

  Future<void> startScan({final bool resetState = false}) async {
    _loading = true;
    _translating = false;
    _textInImage = null;
    _translatedText = null;
    //_languageIdentifier = null;
    if (resetState) notifyListeners();

    // Ensure it gets called on next frame
    await Future<void>.microtask(() async {
      // get image source from dialog
      final ImageSource imageSource = (await dialogHandler.showYesNoDialog(
              'Pick image',
              'Do you want to pick an image from gallery?\nDefault is going to pick an image from camera.'))
          ? ImageSource.gallery
          : ImageSource.camera;

      // get language identifier code from dialog, e.G. fr for french
      //  this identifier code indicates language, which should be actually the language from the text in the image itself
      _languageIdentifier = await dialogHandler.retrieveLanguageInImageDialog(
        'Language',
        'Which language should be translated from?',
      );

      // 1. pick an image
      // 2. parse text from given image
      // 3. translate that text
      return _pickImage(imageSource)
          .then(_parseTextFromImage)
          .catchError((Object error, StackTrace? stackTrace) {
        debugPrint('Error happened; $error; stackTrace: $stackTrace');
      }).whenComplete(() => _translateText(
              fromLanguage: _languageIdentifier,
              toLanguage: TranslateLanguage.english));
    });
  }

  /// Pick an image from given [source]
  Future<XFile?> _pickImage(final ImageSource source) {
    return ImagePicker().pickImage(source: source);
  }

  /// Parse text from given [value] and saves it into [_textInImage]
  ///   Internal widget state gets updated afterwards
  Future<void> _parseTextFromImage(final XFile? value) async {
    if (value == null) {
      _loading = false;
      notifyListeners();
      return;
    }

    // init google ml kit with text detector
    try {
      final RecognizedText recognizedText = await _textRecognizer
          .processImage(InputImage.fromFilePath(value.path));
      _textInImage = recognizedText.text;
    } catch (e) {
      debugPrint('ERROR while processing image: $e');
    }

    // get detected language
    // Currently just make it available via a dialog - an alternative would be the following:
    // await GoogleMlKit.nlp.languageIdentifier().identifyLanguage(textInImage!);

    // update widget state
    _loading = false;
    _translating = true;
    notifyListeners();
  }

  /// Translates text from [_textInImage] and saves the translated text text into [translatedText]
  ///   Internal widget state gets updated afterwards
  Future<void> _translateText({
    required final TranslateLanguage toLanguage,
    required final TranslateLanguage? fromLanguage,
  }) async {
    // just print some stuff in debug mode
    debugPrint('Text in image: $_textInImage');
    debugPrint('ToLanguage: $toLanguage; fromLanguage: $fromLanguage');

    // ensure some text where found in the image, otherwise stop here
    if (_textInImage == null ||
        _textInImage!.isEmpty == true ||
        fromLanguage == null) {
      _translating = false;
      notifyListeners();
      return;
    }

    if (_mlTranslator != null) {
      await _mlTranslator!.close();
      _mlTranslator = null;
    }

    // translate text with google ml kit
    _mlTranslator = OnDeviceTranslator(
      sourceLanguage: fromLanguage,
      targetLanguage: toLanguage,
    );
    try {
      _translatedText = await _mlTranslator!.translateText(_textInImage!);
    } catch (_) {
      debugPrint('ERROR while translating text: $_');
    } /*finally {
       mlTranslator.close();
    }*/

    // update state
    _translating = false;
    notifyListeners();
  }

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TextDetectorController &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  @override
  int get hashCode =>
      _loading.hashCode ^
      _translating.hashCode ^
      _textInImage.hashCode ^
      _translatedText.hashCode ^
      _languageIdentifier.hashCode;

  @override
  Future<void> dispose() async {
    await _textRecognizer.close();
    await _mlTranslator?.close();
    super.dispose();
  }
}
