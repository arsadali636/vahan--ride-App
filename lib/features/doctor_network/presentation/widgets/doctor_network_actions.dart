import 'package:flutter/material.dart';

import '../../../../design_system/components/outline_button.dart';
import '../../../../design_system/components/primary_button.dart';
import '../../../../design_system/spacing/app_spacing.dart';

/// Integration points for the professional-network actions on a public
/// doctor profile: Connect, Follow and Message.
///
/// API contract gap — the current OpenAPI contract does not define
/// connection-request, follow or messaging endpoints, so there is no backend
/// operation to call and no connection/follow state to persist. These buttons
/// are UI integration points only: they surface an honest "coming soon"
/// message instead of pretending an operation succeeded. Implement the real
/// calls when the backend documents those endpoints.
class DoctorNetworkActions extends StatelessWidget {
  const DoctorNetworkActions({super.key});

  void _notAvailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is not available yet'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            label: 'Connect',
            icon: Icons.person_add_alt_1_outlined,
            onPressed: () => _notAvailable(context, 'Connections'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlineButton(
            label: 'Follow',
            icon: Icons.person_outline_rounded,
            onPressed: () => _notAvailable(context, 'Following'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlineButton(
            label: 'Message',
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () => _notAvailable(context, 'Messaging'),
          ),
        ),
      ],
    );
  }
}
