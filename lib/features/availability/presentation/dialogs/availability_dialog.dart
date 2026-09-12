import 'package:flutter/material.dart';

class AvailabilityDialog extends StatelessWidget {
  const AvailabilityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Availability Dialog'),
      content: const Text('This is a dialog for Availability feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
