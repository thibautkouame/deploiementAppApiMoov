import 'package:flutter/material.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/widgets/button_widget.dart';

class ConfirmMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final VoidCallback? onCancel;
  final String? cancelText;

  const ConfirmMessage({
    Key? key,
    required this.message,
    this.confirmText,
    this.onConfirm,
    this.cancelText,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de succès
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.question_mark,
                color: Colors.red,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            // Titre
            Text(
              'Confirmation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            // Bouton Confirmer
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: confirmText ?? 'OK',
                    onPressed: onConfirm ?? () => Navigator.pop(context),
                    textColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ButtonWidget(
                    text: cancelText ?? 'Annuler',
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    textColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
