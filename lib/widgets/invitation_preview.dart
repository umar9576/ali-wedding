import 'package:flutter/material.dart';

import 'invitation_card.dart';

class InvitationPreview extends StatelessWidget {
  const InvitationPreview({
    super.key,
    required this.boundaryKey,
    required this.prefix,
    required this.name,
  });

  final GlobalKey boundaryKey;
  final String prefix;
  final String name;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: RepaintBoundary(
        key: boundaryKey,
        child: InvitationCard(prefix: prefix, name: name),
      ),
    );
  }
}
