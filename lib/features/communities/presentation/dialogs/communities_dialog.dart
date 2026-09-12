import 'package:flutter/material.dart';

class CommunitiesDialog extends StatelessWidget {
  const CommunitiesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Communities Dialog'),
      content: const Text('This is a dialog for Communities feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
