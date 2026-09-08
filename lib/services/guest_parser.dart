import '../models/guest.dart';
import 'arabic_normalizer.dart';

class GuestParser {
  GuestParser._();

  static const List<String> knownPrefixes = [
    'الدكتورة',
    'الدكتور',
    'الآنسة',
    'الأستاذة',
    'الأستاذ',
    'الاستاذ',
    'المهندسة',
    'المهندس',
    'المحامية',
    'المحامي',
    'المعلمة',
    'المعلم',
    'السيدة',
    'السيد',
    'الشيخة',
    'الشيخ',
    'الحاجة',
    'الحاج',
    'الأخت',
    'الأخ',
    'الخالة',
    'العمة',
    'الخال',
    'العم',
  ];

  static final List<String> _prefixesLongestFirst = List<String>.from(
    knownPrefixes,
  )..sort((a, b) => b.length.compareTo(a.length));

  static List<Guest> parse(String content) {
    final guests = <Guest>[];
    final lines = content.split(RegExp(r'\r?\n'));
    var index = 0;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }

      final parsed = _parseLine(line);
      if (parsed == null) {
        continue;
      }

      index += 1;
      final prefix = parsed.$1;
      final name = parsed.$2;
      guests.add(
        Guest(
          id: 'g${index.toString().padLeft(4, '0')}',
          prefix: prefix,
          name: name,
          searchableText: ArabicNormalizer.normalize('$prefix $name'),
        ),
      );
    }

    return guests;
  }

  static (String, String)? _parseLine(String line) {
    if (line.contains('|')) {
      final parts = line.split('|');
      final prefix = _cleanPrefix(parts.first);
      final name = parts.sublist(1).join('|').trim();
      if (name.isEmpty) {
        return null;
      }
      return (prefix, name);
    }

    for (final prefix in _prefixesLongestFirst) {
      if (line == prefix || !line.startsWith(prefix)) {
        continue;
      }

      final remainder = line.substring(prefix.length);
      if (remainder.startsWith(' ') ||
          remainder.startsWith('/') ||
          remainder.startsWith('\t')) {
        final name = _cleanName(remainder);
        if (name.isEmpty) {
          return null;
        }
        return (_cleanPrefix(prefix), name);
      }
    }

    return ('', line);
  }

  static String _cleanPrefix(String value) {
    return value.replaceAll('/', '').trim();
  }

  static String _cleanName(String value) {
    var name = value.trim();
    if (name.startsWith('/')) {
      name = name.substring(1).trim();
    }
    return name;
  }
}
