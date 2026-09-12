import 'package:flutter/material.dart';

class ApplicationsDialog extends StatelessWidget {
  const ApplicationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Applications Dialog'),
      content: const Text('This is a dialog for Applications feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
