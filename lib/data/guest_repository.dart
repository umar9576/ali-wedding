import 'package:flutter/services.dart';

import '../models/guest.dart';
import '../services/arabic_normalizer.dart';
import '../services/guest_parser.dart';

abstract class GuestRepository {
  Future<List<Guest>> loadGuests();

  Guest? findById(String id);

  List<Guest> search(String query, {int limit = 15});
}

class AssetGuestRepository implements GuestRepository {
  AssetGuestRepository({this.assetPath = 'assets/guests/guests.txt'});

  final String assetPath;

  List<Guest> _guests = const [];
  bool _loaded = false;

  List<Guest> get guests => _guests;

  bool get isLoaded => _loaded;

  @override
  Future<List<Guest>> loadGuests() async {
    if (_loaded) {
      return _guests;
    }

    final raw = await rootBundle.loadString(assetPath);
    final parsed = GuestParser.parse(raw);
    if (parsed.isEmpty) {
      throw const FormatException('empty guest list');
    }

    _guests = parsed;
    _loaded = true;
    return _guests;
  }

  @override
  Guest? findById(String id) {
    for (final guest in _guests) {
      if (guest.id == id) {
        return guest;
      }
    }
    return null;
  }

  @override
  List<Guest> search(String query, {int limit = 15}) {
    final normalized = ArabicNormalizer.normalize(query);
    if (normalized.length < 2) {
      return const [];
    }

    final startsWith = <Guest>[];
    final contains = <Guest>[];

    for (final guest in _guests) {
      if (!guest.searchableText.contains(normalized)) {
        continue;
      }
      if (guest.searchableText.startsWith(normalized) ||
          guest.searchableText.contains(' $normalized')) {
        startsWith.add(guest);
      } else {
        contains.add(guest);
      }
      if (startsWith.length + contains.length >= limit * 2) {
        break;
      }
    }

    return [...startsWith, ...contains].take(limit).toList(growable: false);
  }
}
