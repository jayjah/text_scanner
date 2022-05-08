// ignore_for_file: curly_braces_in_flow_control_structures, unawaited_futures

import 'package:flutter/material.dart';
import 'package:text_in_image_detector/state/text_detector_controller.dart';

/// Widget does the following things:
///   1. Get an image from gallery OR camera. The decision is based on a dialog.
///       Afterwards another dialog is shown, where the user can enter the language identifier.
///       This language identifier should represent the language, which is visible in the text in the image.
///   2. Extract any text from the image
///   3. Translate the extracted text to an other language. Currently this is hard coded to `en`

class TextDetectorWidget extends StatelessWidget {
  const TextDetectorWidget({
    Key? key,
    required this.textScannerController,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.spacerWidget = const SizedBox(
      height: 55,
    ),
    this.loadingWidget = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
  }) : super(key: key);
  final TextDetectorController textScannerController;
  final EdgeInsets padding;
  final Widget spacerWidget;
  final Widget loadingWidget;
  @override
  Widget build(BuildContext context) {
    // default helper|error text style
    const TextStyle helperOrErrorStyle = TextStyle(
      fontSize: 16,
    );
    const Widget textIsBeingTranslatedWidget = Center(
      child: Text(
        'Please wait, text is being translated...',
        style: helperOrErrorStyle,
      ),
    );

    return Material(
      child: AnimatedBuilder(
        animation: textScannerController,
        builder: (BuildContext context, Widget? resetButton) {
          // build child widget from internal state
          late final Widget child;
          if (textScannerController.isLoading)
            child = loadingWidget;
          else if (textScannerController.isTranslating)
            child = textIsBeingTranslatedWidget;
          else /* show text from the image and the translated text, if available */
            child = SingleChildScrollView(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  spacerWidget,
                  resetButton!,
                  spacerWidget,
                  if (textScannerController.textFromImage?.isNotEmpty ==
                      true) ...<Widget>[
                    const Text(
                      'Text to translate:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      textScannerController.textFromImage!,
                      textAlign: TextAlign.center,
                    ),
                  ] else
                    const Text(
                      'ERROR - No translated text were found',
                      style: helperOrErrorStyle,
                    ),
                  spacerWidget,
                  if (textScannerController.translatedText?.isNotEmpty ==
                      true) ...<Widget>[
                    const Text(
                      'Translated text:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      textScannerController.translatedText!,
                      textAlign: TextAlign.center,
                    )
                  ] else
                    const Text(
                      'ERROR - Could not translate text',
                      style: helperOrErrorStyle,
                    ),
                  spacerWidget,
                ],
              ),
            );

          return child;
        },
        child: _ResetButton(
          onPressed: () => textScannerController.startScan(
            resetState: true,
          ),
        ),
      ),
    );
  }
}

// Simple wrapped [IconButton]
class _ResetButton extends StatelessWidget {
  const _ResetButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        color: Colors.red,
        onPressed: onPressed,
        icon: const Icon(Icons.close),
      ),
    );
  }
}
