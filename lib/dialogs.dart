// ignore_for_file: unused_element

import 'package:flutter/cupertino.dart' show showCupertinoDialog;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:google_ml_kit/google_ml_kit.dart';

/// Navigator Key
///   Should be used in a [MaterialApp], otherwise [AppDialogs] will fail to show any dialog!
final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

/// Simple Dialogs class, which uses internally [navigatorKey] for BuildContext reference
class AppDialogs {
  const AppDialogs();

  Future<bool> showYesNoDialog(
    final String title,
    final String message,
  ) async {
    assert(navigatorKey.currentContext != null,
        'navigatorKeys context is NULL, which leads to misuse of navigatorKey. Use navigatorKey in MaterialApp therefore');

    return await showCupertinoDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) => _DialogWidget(
            title: title,
            message: message,
            additionalWidgetBuilder: (BuildContext context) => const <Widget>[
              _YesNoButtons(),
              _CloseButton(),
            ],
          ),
        ) ==
        true;
  }

  Future<TranslateLanguage?> retrieveLanguageInImageDialog(
    final String title,
    final String message,
  ) async {
    assert(navigatorKey.currentContext != null,
        'navigatorKeys context is NULL, which leads to misuse of navigatorKey. Use navigatorKey in MaterialApp therefore');

    final GlobalKey<_DropDownMenuState> key = GlobalKey<_DropDownMenuState>();
    await showCupertinoDialog<void>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => _DialogWidget(
        title: title,
        message: message,
        additionalWidgetBuilder: (BuildContext context) => <Widget>[
          _DropDownMenu(key: key),
          const _OkButton(),
        ],
      ),
    );
    return key.currentState?.value;
  }
}

typedef ListWidgetBuilder = List<Widget> Function(BuildContext context);

class _DropDownMenu extends StatefulWidget {
  const _DropDownMenu({super.key});

  @override
  State<_DropDownMenu> createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<_DropDownMenu> {
  TranslateLanguage? value;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<TranslateLanguage>(
      items: TranslateLanguage.values
          .map(
            (TranslateLanguage e) => DropdownMenuItem<TranslateLanguage>(
              value: e,
              child: Text(e.name),
            ),
          )
          .toList(growable: false),
      onChanged: (TranslateLanguage? item) {
        if (mounted)
          // ignore: curly_braces_in_flow_control_structures
          setState(() {
            value = item;
          });
      },
      value: value,
    );
  }
}

// Simple Dialog Widget - [Scaffold] widget with a [Column]
class _DialogWidget extends StatelessWidget {
  const _DialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.additionalWidgetBuilder,
    this.spacer = const Spacer(),
    this.divider = const VerticalDivider(),
  });
  final String title;
  final String message;
  final Widget spacer;
  final Widget divider;
  final ListWidgetBuilder additionalWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              spacer,
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              divider,
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...additionalWidgetBuilder(context),
              spacer,
            ],
          ),
        ),
      ),
    );
  }
}

// Simple yes - no buttons
class _YesNoButtons extends StatelessWidget {
  const _YesNoButtons({super.key});

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
  const _CloseButton({super.key});

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

// Simple ok button
class _OkButton extends StatelessWidget {
  const _OkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: Navigator.of(context).maybePop,
      child: const Text(
        'Ok',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
