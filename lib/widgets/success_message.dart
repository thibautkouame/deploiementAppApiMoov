import 'package:flutter/material.dart';
import 'package:fitness/theme/theme.dart';
import 'package:fitness/widgets/button_widget.dart';

class SuccessMessage extends StatelessWidget {
  final String message;
  final VoidCallback onContinue;

  const SuccessMessage({
    Key? key,
    required this.message,
    required this.onContinue,
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
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sentiment_satisfied_alt,
                color: Colors.white,
                size: 40,
              ),
            ),
            SizedBox(height: 20),
            // Titre
            Text(
              'Succès',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
            // Bouton Continue
            SizedBox(
              width: double.infinity,
              child: ButtonWidget(
                text: 'Continuer',
                onPressed: onContinue,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
