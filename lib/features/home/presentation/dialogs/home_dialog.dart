import 'package:flutter/material.dart';

class HomeDialog extends StatelessWidget {
  const HomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Home Dialog'),
      content: const Text('This is a dialog for Home feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
