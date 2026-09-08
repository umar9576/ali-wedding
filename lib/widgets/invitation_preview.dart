import 'package:flutter/material.dart';

import 'invitation_card.dart';

class InvitationPreview extends StatelessWidget {
  const InvitationPreview({
    super.key,
    required this.prefix,
    required this.name,
  });

  final String prefix;
  final String name;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      child: InvitationCard(prefix: prefix, name: name),
    );
  }
}
