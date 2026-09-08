import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/guest_repository.dart';
import 'models/guest.dart';
import 'platform/url_strategy.dart';
import 'screens/guest_search_screen.dart';
import 'screens/invitation_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/guests_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  runApp(const InvitationApp());
}

class InvitationApp extends StatefulWidget {
  const InvitationApp({super.key, this.repository});

  final GuestRepository? repository;

  @override
  State<InvitationApp> createState() => _InvitationAppState();
}

class _InvitationAppState extends State<InvitationApp> {
  late final GuestRepository _repository;
  List<Guest> _guests = const [];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AssetGuestRepository();
    final cached = _repository;
    if (cached is AssetGuestRepository && cached.isLoaded) {
      _guests = cached.guests;
      _loading = false;
    } else {
      _loadGuests();
    }
  }

  Future<void> _loadGuests() async {
    try {
      final guests = await _repository.loadGuests();
      if (!mounted) {
        return;
      }
      setState(() {
        _guests = guests;
        _loading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GuestsScope(
      repository: _repository,
      guests: _guests,
      loading: _loading,
      loadFailed: _loadFailed,
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final uri = Uri.parse(name);
    final path = uri.path.isEmpty ? '/' : uri.path;

    final inviteMatch = RegExp(r'^/invite/([^/]+)/?$').firstMatch(path);
    if (inviteMatch != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => InvitationScreen(guestId: inviteMatch.group(1)!),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const GuestSearchScreen(),
    );
  }
}
