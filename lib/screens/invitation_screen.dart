import 'package:flutter/material.dart';

import '../models/guest.dart';
import '../models/invitation_kind.dart';
import '../services/invitation_export_service.dart';
import '../services/share_service.dart';
import '../services/share_types.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/guests_scope.dart';
import '../widgets/invitation_layout.dart';
import '../widgets/invitation_preview.dart';
import '../widgets/prefix_field.dart';
import '../widgets/seat_count_field.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key, required this.guestId});

  final String guestId;

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
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
    precacheImage(const AssetImage(InvitationLayout.groomAsset), context);
    precacheImage(const AssetImage(InvitationLayout.fatherAsset), context);
  }

  Future<void> _detectShareSupport() async {
    final supported = await _shareService.supportsFileShare;
    if (mounted) {
      setState(() => _supportsFileShare = supported);
    }
  }

  Future<void> _share({
    required Guest guest,
    required InvitationKind kind,
    required String prefix,
    required String name,
    required int seatCount,
  }) async {
    if (_busy) {
      return;
    }

    setState(() => _busy = true);
    try {
      final png = await _exportService.capturePng(
        kind: kind,
        prefix: prefix,
        name: name,
        seatCount: seatCount,
      );
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

    return _InvitationBody(
      guest: guest,
      busy: _busy,
      supportsFileShare: _supportsFileShare,
      onShare:
          ({
            required InvitationKind kind,
            required String prefix,
            required String name,
            required int seatCount,
          }) => _share(
            guest: guest,
            kind: kind,
            prefix: prefix,
            name: name,
            seatCount: seatCount,
          ),
    );
  }
}

typedef _ShareCallback =
    Future<void> Function({
      required InvitationKind kind,
      required String prefix,
      required String name,
      required int seatCount,
    });

class _InvitationBody extends StatefulWidget {
  const _InvitationBody({
    required this.guest,
    required this.busy,
    required this.supportsFileShare,
    required this.onShare,
  });

  final Guest guest;
  final bool busy;
  final bool supportsFileShare;
  final _ShareCallback onShare;

  @override
  State<_InvitationBody> createState() => _InvitationBodyState();
}

class _InvitationBodyState extends State<_InvitationBody> {
  late final TextEditingController _prefixController;
  late final TextEditingController _nameController;
  InvitationKind _kind = InvitationKind.groom;
  int _seatCount = InvitationLayout.defaultSeatCount;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController(text: widget.guest.prefix);
    _nameController = TextEditingController(text: widget.guest.name);
  }

  @override
  void didUpdateWidget(covariant _InvitationBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guest.id != widget.guest.id) {
      _prefixController.text = widget.guest.prefix;
      _nameController.text = widget.guest.name;
    }
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _prefix => _prefixController.text.trim();
  String get _name => _nameController.text.trim();

  @override
  Widget build(BuildContext context) {
    final shareLabel =
        widget.supportsFileShare
            ? AppStrings.shareInvitation
            : AppStrings.shareWhatsApp;
    final headerName = InvitationLayout.guestLine(_prefix, _name);

    return AppShell(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                        headerName.isEmpty ? widget.guest.name : headerName,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    SegmentedButton<InvitationKind>(
                      segments: const [
                        ButtonSegment(
                          value: InvitationKind.groom,
                          label: Text(AppStrings.cardGroom),
                        ),
                        ButtonSegment(
                          value: InvitationKind.father,
                          label: Text(AppStrings.cardFather),
                        ),
                      ],
                      selected: {_kind},
                      showSelectedIcon: false,
                      onSelectionChanged: (selected) {
                        setState(() => _kind = selected.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    PrefixField(
                      controller: _prefixController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            key: const Key('name-field'),
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            textAlign: TextAlign.right,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: AppStrings.nameLabel,
                              hintText: AppStrings.nameHint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: SeatCountField(
                            value: _seatCount,
                            onChanged:
                                (value) => setState(() => _seatCount = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: InvitationPreview(
                    kind: _kind,
                    prefix: _prefix,
                    name: _name,
                    seatCount: _seatCount,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed:
                          widget.busy
                              ? null
                              : () => widget.onShare(
                                kind: _kind,
                                prefix: _prefix,
                                name: _name,
                                seatCount: _seatCount,
                              ),
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
                          widget.busy
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
                          widget.busy
                              ? null
                              : () => Navigator.of(context).maybePop(),
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
