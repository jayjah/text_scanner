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
                  const Spacer(),
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
