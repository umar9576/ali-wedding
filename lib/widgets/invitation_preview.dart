import 'package:flutter/material.dart';

import '../models/invitation_kind.dart';
import 'invitation_card.dart';

class InvitationPreview extends StatelessWidget {
  const InvitationPreview({
    super.key,
    required this.kind,
    required this.prefix,
    required this.name,
    required this.seatCount,
  });

  final InvitationKind kind;
  final String prefix;
  final String name;
  final int seatCount;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      child: InvitationCard(
        kind: kind,
        prefix: prefix,
        name: name,
        seatCount: seatCount,
      ),
    );
  }
}
