import 'package:flutter/material.dart';

class ReportingDialog extends StatelessWidget {
  const ReportingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reporting Dialog'),
      content: const Text('This is a dialog for Reporting feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
