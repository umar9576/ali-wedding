import 'package:flutter/material.dart';

import '../data/guest_repository.dart';
import '../models/guest.dart';

class GuestsScope extends InheritedWidget {
  const GuestsScope({
    super.key,
    required this.repository,
    required this.guests,
    required this.loading,
    required this.loadFailed,
    required super.child,
  });

  final GuestRepository repository;
  final List<Guest> guests;
  final bool loading;
  final bool loadFailed;

  static GuestsScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GuestsScope>();
    assert(scope != null, 'GuestsScope is missing');
    return scope!;
  }

  @override
  bool updateShouldNotify(GuestsScope oldWidget) {
    return loading != oldWidget.loading ||
        loadFailed != oldWidget.loadFailed ||
        guests != oldWidget.guests;
  }
}
