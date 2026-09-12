import 'package:flutter/material.dart';

class AuthDialog extends StatelessWidget {
  const AuthDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auth Dialog'),
      content: const Text('This is a dialog for Auth feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
