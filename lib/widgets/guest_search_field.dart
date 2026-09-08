import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GuestSearchField extends StatelessWidget {
  const GuestSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      autofocus: false,
      decoration: const InputDecoration(
        hintText: AppStrings.searchHint,
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.goldDeep),
      ),
    );
  }
}
