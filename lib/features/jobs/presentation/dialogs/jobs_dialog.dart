import 'package:flutter/material.dart';

class JobsDialog extends StatelessWidget {
  const JobsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jobs Dialog'),
      content: const Text('This is a dialog for Jobs feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
