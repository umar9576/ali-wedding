import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrefixField extends StatelessWidget {
  const PrefixField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  static const List<String> suggestions = [
    'الدكتور',
    'السيد',
    'الأستاذ',
    'المهندس',
    'الشيخ',
    'الحاج',
    'السيدة',
  ];

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  void _apply(String value) {
    if (controller.text != value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final current = controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('prefix-field'),
          controller: controller,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.right,
          onChanged: onChanged,
          decoration: const InputDecoration(
            labelText: AppStrings.prefixLabel,
            hintText: AppStrings.prefixHint,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _PrefixChip(
                label: AppStrings.prefixNone,
                selected: current.isEmpty,
                onSelected: () => _apply(''),
              ),
              ...suggestions.map((prefix) {
                return _PrefixChip(
                  label: prefix,
                  selected: current == prefix,
                  onSelected: () => _apply(prefix),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrefixChip extends StatelessWidget {
  const _PrefixChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        visualDensity: VisualDensity.compact,
        labelStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 14,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : AppColors.ink,
        ),
        selectedColor: AppColors.goldDeep,
        backgroundColor: Colors.white.withValues(alpha: 0.86),
        side: BorderSide(
          color:
              selected
                  ? AppColors.goldDeep
                  : AppColors.gold.withValues(alpha: 0.55),
        ),
        showCheckmark: false,
      ),
    );
  }
}
