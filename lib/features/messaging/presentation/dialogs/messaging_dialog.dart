import 'package:flutter/material.dart';

class MessagingDialog extends StatelessWidget {
  const MessagingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Messaging Dialog'),
      content: const Text('This is a dialog for Messaging feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
