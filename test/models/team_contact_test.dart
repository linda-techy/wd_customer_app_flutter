import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/team_contact.dart';

void main() {
  group('TeamContact.fromJson', () {
    test('parses a full contact payload', () {
      final json = {
        'userId': 12,
        'name': 'Sita Engineer',
        'designation': 'Site Engineer',
        'role': 'SITE_ENGINEER',
        'phone': '9876543210',
        'email': 'sita@walldot.com',
        'photoUrl': 'https://cdn/sita.jpg',
      };

      final c = TeamContact.fromJson(json);

      expect(c.userId, 12);
      expect(c.name, 'Sita Engineer');
      expect(c.designation, 'Site Engineer');
      expect(c.role, 'SITE_ENGINEER');
      expect(c.phone, '9876543210');
      expect(c.email, 'sita@walldot.com');
      expect(c.photoUrl, 'https://cdn/sita.jpg');
      expect(c.hasPhone, isTrue);
      expect(c.hasEmail, isTrue);
    });

    test('coerces numeric userId and applies defaults', () {
      final c = TeamContact.fromJson({'userId': 5.0});

      expect(c.userId, 5);
      expect(c.name, 'Unnamed'); // default
      expect(c.designation, '');
      expect(c.role, '');
      expect(c.phone, isNull);
      expect(c.email, isNull);
      expect(c.photoUrl, isNull);
      expect(c.hasPhone, isFalse);
      expect(c.hasEmail, isFalse);
    });

    test('hasPhone/hasEmail false on empty strings', () {
      final c = TeamContact.fromJson({
        'userId': 1,
        'phone': '',
        'email': '',
      });

      expect(c.hasPhone, isFalse);
      expect(c.hasEmail, isFalse);
    });
  });
}
