// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/cupertino.dart' show showCupertinoDialog;
import 'package:flutter/material.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  static Future<bool> showDialog(String title, String message) async {
    final bool? result = await showCupertinoDialog<bool>(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) => Material(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                ],
              ),
            ));

    return result == true;
  }
}

class _YesNoButtons extends StatelessWidget {
  const _YesNoButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).maybePop(false),
            child: const Text('No')),
        TextButton(
            onPressed: () => Navigator.of(context).maybePop(true),
            child: const Text('Yes'))
      ],
    );
  }
}
