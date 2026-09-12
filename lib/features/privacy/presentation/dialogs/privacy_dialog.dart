import 'package:flutter/material.dart';

class PrivacyDialog extends StatelessWidget {
  const PrivacyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy Dialog'),
      content: const Text('This is a dialog for Privacy feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
