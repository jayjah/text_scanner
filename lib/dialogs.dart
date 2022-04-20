// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:io';

import 'package:flutter/cupertino.dart' show showCupertinoDialog;
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class AppDialogs {
  const AppDialogs();

  Future<bool> showDialog(String title, String message) async {
    final bool? result = await showCupertinoDialog<bool>(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => Material(
              child: Column(
                children: <Widget>[
                  const Spacer(),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const VerticalDivider(),
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
                  const Spacer(),
                ],
              ),
            ));

    return result == true;
  }

  Future<String> languageCode(String title, String message) async {
    final TextEditingController textController = TextEditingController()
      ..text = 'fr';

    await showCupertinoDialog<String>(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => Scaffold(
              resizeToAvoidBottomInset: true,
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const VerticalDivider(),
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
                    const Spacer(),
                  ],
                ),
              ),
            ));

    return textController.text;
  }
}

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
            child: Text('Yes', style: style.copyWith(color: Colors.green)))
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => exit(0),
      child: const Text(
        'Exit App',
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}
