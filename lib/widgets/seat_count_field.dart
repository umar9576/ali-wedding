import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'invitation_layout.dart';

class SeatCountField extends StatelessWidget {
  const SeatCountField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: AppStrings.seatLabel,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            onPressed:
                value > InvitationLayout.minSeatCount
                    ? () => onChanged(value - 1)
                    : null,
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onPressed:
                value < InvitationLayout.maxSeatCount
                    ? () => onChanged(value + 1)
                    : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: AppColors.goldDeep),
    );
  }
}
