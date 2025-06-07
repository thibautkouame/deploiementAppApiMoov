import 'package:flutter/material.dart';

import '../theme/theme.dart';

Future showLoadingDialog(
  BuildContext context, {
  String message = 'Veuillez patienter...',
  bool dismissible = false,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,

        elevation: 0,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}
