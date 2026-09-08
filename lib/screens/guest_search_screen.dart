import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/guest_search_field.dart';
import '../widgets/guest_tile.dart';
import '../widgets/guests_scope.dart';

class GuestSearchScreen extends StatefulWidget {
  const GuestSearchScreen({super.key});

  @override
  State<GuestSearchScreen> createState() => _GuestSearchScreenState();
}

class _GuestSearchScreenState extends State<GuestSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openInvitation(Guest guest) {
    Navigator.of(context).pushNamed('/invite/${guest.id}');
  }

  @override
  Widget build(BuildContext context) {
    final scope = GuestsScope.of(context);

    return AppShell(
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appTitle)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                GuestSearchField(controller: _controller),
                const SizedBox(height: 18),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) {
                      return _buildBody(scope, value.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(GuestsScope scope, String query) {
    if (scope.loading) {
      return const _Message(AppStrings.loading);
    }
    if (scope.loadFailed) {
      return const _Message(AppStrings.loadError);
    }

    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const _Message(AppStrings.searchPrompt);
    }

    final matches = scope.repository.search(trimmed);
    if (matches.isEmpty) {
      return const _Message(AppStrings.notFound);
    }

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final guest = matches[index];
        return GuestTile(guest: guest, onTap: () => _openInvitation(guest));
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: AppColors.ink.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
