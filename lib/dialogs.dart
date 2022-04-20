// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/cupertino.dart' show showCupertinoDialog;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

/// Simple Dialogs class, which uses internally [navigatorKey] for BuildContext reference
class AppDialogs {
  const AppDialogs();
  final Widget _spacer = const Spacer();
  final Widget _divider = const VerticalDivider();

  Future<bool> showDialog(String title, String message) async {
    return await showCupertinoDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) => Material(
            child: Column(
              children: <Widget>[
                _spacer,
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _divider,
                Center(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const _YesNoButtons(),
                const _CloseButton(),
                _spacer,
              ],
            ),
          ),
        ) ==
        true;
  }

  Future<String> languageCode(String title, String message) async {
    final TextEditingController textController = TextEditingController()
      ..text = 'fr';

    await showCupertinoDialog<String>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: <Widget>[
              _spacer,
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _divider,
              Center(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextField(
                controller: textController,
              ),
              TextButton(
                onPressed: Navigator.of(context).maybePop,
                child: const Text(
                  'Ok',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              _spacer,
            ],
          ),
        ),
      ),
    );

    // Storing text temporary from [textController] to close it afterwards
    final String text = textController.text;
    textController.dispose();

    return text;
  }
}

// Simple yes - no buttons
class _YesNoButtons extends StatelessWidget {
  const _YesNoButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(fontSize: 16);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).maybePop(false),
            child: Text(
              'No',
              style: style.copyWith(color: Colors.red),
            )),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(true),
          child: Text(
            'Yes',
            style: style.copyWith(color: Colors.green),
          ),
        )
      ],
    );
  }
}

// Simple close app button
class _CloseButton extends StatelessWidget {
  const _CloseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () =>
          SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop'),
      child: const Text(
        'Exit App',
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}
