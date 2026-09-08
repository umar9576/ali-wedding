import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../services/invitation_export_service.dart';
import '../services/share_service.dart';
import '../services/share_types.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/guests_scope.dart';
import '../widgets/invitation_layout.dart';
import '../widgets/invitation_preview.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key, required this.guestId});

  final String guestId;

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  final InvitationExportService _exportService =
      const InvitationExportService();
  final ShareService _shareService = ShareService();

  bool _busy = false;
  bool _supportsFileShare = false;

  @override
  void initState() {
    super.initState();
    _detectShareSupport();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(InvitationLayout.imageAsset), context);
  }

  Future<void> _detectShareSupport() async {
    final supported = await _shareService.supportsFileShare;
    if (mounted) {
      setState(() => _supportsFileShare = supported);
    }
  }

  Future<void> _share(Guest guest) async {
    if (_busy) {
      return;
    }

    setState(() => _busy = true);
    try {
      final png = await _exportService.capturePng(_boundaryKey);
      if (!mounted) {
        return;
      }

      final outcome = await _shareService.sharePng(
        pngBytes: png,
        fileName: 'invitation-${guest.id}.png',
        text: AppStrings.whatsappMessage,
      );

      if (!mounted) {
        return;
      }

      switch (outcome) {
        case ShareOutcome.shared:
        case ShareOutcome.cancelled:
          break;
        case ShareOutcome.fallbackDownloadAndWhatsApp:
          _showSnack(AppStrings.shareFallback);
        case ShareOutcome.unavailable:
        case ShareOutcome.failed:
          _showSnack(AppStrings.shareError);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(AppStrings.shareError);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scope = GuestsScope.of(context);

    if (scope.loading) {
      return const AppShell(
        child: Scaffold(body: Center(child: Text(AppStrings.loading))),
      );
    }

    if (scope.loadFailed) {
      return AppShell(
        child: Scaffold(
          body: _MissingState(onBack: () => Navigator.of(context).maybePop()),
        ),
      );
    }

    final guest = scope.repository.findById(widget.guestId);
    if (guest == null) {
      return AppShell(
        child: Scaffold(
          body: _MissingState(onBack: () => Navigator.of(context).maybePop()),
        ),
      );
    }

    final shareLabel =
        _supportsFileShare
            ? AppStrings.shareInvitation
            : AppStrings.shareWhatsApp;

    return AppShell(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: AppStrings.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        guest.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: InvitationPreview(
                    boundaryKey: _boundaryKey,
                    prefix: guest.prefix,
                    name: guest.name,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: _busy ? null : () => _share(guest),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.whatsapp,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.whatsapp.withValues(
                          alpha: 0.5,
                        ),
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child:
                          _busy
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                              : Text(shareLabel),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed:
                          _busy ? null : () => Navigator.of(context).maybePop(),
                      child: const Text(
                        AppStrings.back,
                        style: TextStyle(fontSize: 16, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingState extends StatelessWidget {
  const _MissingState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.guestMissing,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.6),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: onBack, child: const Text(AppStrings.back)),
            ],
          ),
        ),
      ),
    );
  }
}
