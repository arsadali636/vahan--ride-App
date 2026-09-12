import 'package:flutter/material.dart';

class OnboardingDialog extends StatelessWidget {
  const OnboardingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Onboarding Dialog'),
      content: const Text('This is a dialog for Onboarding feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
