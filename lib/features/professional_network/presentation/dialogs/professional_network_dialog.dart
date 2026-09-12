import 'package:flutter/material.dart';

class ProfessionalNetworkDialog extends StatelessWidget {
  const ProfessionalNetworkDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ProfessionalNetwork Dialog'),
      content: const Text('This is a dialog for ProfessionalNetwork feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
