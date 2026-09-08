import 'package:ali_marriage/data/guest_repository.dart';
import 'package:ali_marriage/main.dart';
import 'package:ali_marriage/services/arabic_normalizer.dart';
import 'package:ali_marriage/services/guest_parser.dart';
import 'package:ali_marriage/widgets/invitation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ArabicNormalizer strips tashkeel and hamza variants', () {
    expect(
      ArabicNormalizer.normalize('  أَحْمَد   إِبراهيم  '),
      'احمد ابراهيم',
    );
  });

  test('GuestParser supports pipe and plain Arabic formats', () {
    const raw = '''
# comment
الدكتور|أحمد محمد الحلبي
السيد محمد أحمد علي
الأستاذ|خالد محمود
''';
    final guests = GuestParser.parse(raw);
    expect(guests.length, 3);
    expect(guests[0].id, 'g0001');
    expect(guests[0].prefix, 'الدكتور');
    expect(guests[0].name, 'أحمد محمد الحلبي');
    expect(guests[1].prefix, 'السيد');
    expect(guests[1].name, 'محمد أحمد علي');
    expect(guests[2].id, 'g0003');
  });

  test('Untitled guests keep the full name without a prefix', () {
    const raw = '''
|نائل عطار
ابناء المرحوم الغالي سامح عادل مستو
''';
    final guests = GuestParser.parse(raw);
    expect(guests.length, 2);
    expect(guests[0].prefix, isEmpty);
    expect(guests[0].name, 'نائل عطار');
    expect(guests[1].prefix, isEmpty);
    expect(guests[1].name, 'ابناء المرحوم الغالي سامح عادل مستو');
  });

  test('Duplicate names receive distinct ids', () {
    const raw = '''
السيد|محمد أحمد
الدكتور|محمد أحمد
''';
    final guests = GuestParser.parse(raw);
    expect(guests[0].id, isNot(guests[1].id));
    expect(guests[0].name, guests[1].name);
  });

  test('Search matches names after Arabic normalization', () {
    final guests = GuestParser.parse(
      'الدكتور|أحمد محمد الحلبي\nالسيد|محمد أحمد علي\n',
    );
    final query = ArabicNormalizer.normalize('احمد');
    expect(query, 'احمد');
    expect(guests[0].searchableText.contains(query), isTrue);
    expect(guests[1].searchableText.contains(query), isTrue);
  });

  testWidgets('Search screen is Arabic-only', (tester) async {
    final repository = AssetGuestRepository();
    await repository.loadGuests();
    await tester.pumpWidget(InvitationApp(repository: repository));

    expect(find.text('دعوات الزفاف'), findsOneWidget);
    expect(find.text('ابحث عن اسم المدعو'), findsOneWidget);
    expect(find.text('اكتب اسم المدعو للبحث عن الدعوة'), findsOneWidget);
  });

  testWidgets('Invitation card fits long Arabic names', (tester) async {
    tester.view.physicalSize = const Size(1100, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: InvitationCard(
            prefix: 'الدكتور',
            name: 'محمد أحمد عبد الرحمن الحلبي',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('الدكتور / محمد أحمد عبد الرحمن الحلبي'),
      findsOneWidget,
    );
  });
}
