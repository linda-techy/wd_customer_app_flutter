import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/support_models.dart';

void main() {
  group('TicketReply.fromJson', () {
    test('parses a real-shaped reply payload', () {
      final json = {
        'id': 'r-1',
        'userId': 'u-9',
        'userType': 'STAFF',
        'userName': 'Support Agent',
        'message': 'We are on it',
        'attachmentUrl': 'https://cdn/a.pdf',
        'createdAt': '2026-05-29T10:00:00',
      };

      final r = TicketReply.fromJson(json);

      expect(r.id, 'r-1');
      expect(r.userId, 'u-9');
      expect(r.userType, 'STAFF');
      expect(r.userName, 'Support Agent');
      expect(r.message, 'We are on it');
      expect(r.attachmentUrl, 'https://cdn/a.pdf');
      expect(r.createdAt, '2026-05-29T10:00:00');
      expect(r.isStaff, isTrue);
    });

    test('isStaff is false for non-STAFF userType and nulls attachment', () {
      final r = TicketReply.fromJson({
        'id': 'r-2',
        'userType': 'CUSTOMER',
      });

      expect(r.id, 'r-2');
      expect(r.userType, 'CUSTOMER');
      expect(r.attachmentUrl, isNull);
      expect(r.isStaff, isFalse);
    });

    test('applies defaults on empty json', () {
      final r = TicketReply.fromJson({});

      expect(r.id, '');
      expect(r.userId, '');
      expect(r.userType, '');
      expect(r.userName, '');
      expect(r.message, '');
      expect(r.attachmentUrl, isNull);
      expect(r.createdAt, '');
      expect(r.isStaff, isFalse);
    });
  });

  group('SupportTicket.fromJson', () {
    test('parses a full ticket payload with nested replies', () {
      final json = {
        'id': 't-1',
        'ticketNumber': 'TKT-1001',
        'subject': 'Water leak',
        'description': 'Leak in bathroom',
        'category': 'WARRANTY',
        'priority': 'HIGH',
        'status': 'OPEN',
        'projectId': 49,
        'createdAt': '2026-05-28T08:00:00',
        'updatedAt': '2026-05-29T08:00:00',
        'resolvedAt': null,
        'replies': [
          {
            'id': 'r-1',
            'userType': 'STAFF',
            'userName': 'Agent',
            'message': 'Looking into it',
            'createdAt': '2026-05-29T09:00:00',
          },
        ],
      };

      final t = SupportTicket.fromJson(json);

      expect(t.id, 't-1');
      expect(t.ticketNumber, 'TKT-1001');
      expect(t.subject, 'Water leak');
      expect(t.description, 'Leak in bathroom');
      expect(t.category, 'WARRANTY');
      expect(t.priority, 'HIGH');
      expect(t.status, 'OPEN');
      expect(t.projectId, 49);
      expect(t.createdAt, '2026-05-28T08:00:00');
      expect(t.updatedAt, '2026-05-29T08:00:00');
      expect(t.resolvedAt, isNull);
      expect(t.replies, hasLength(1));
      expect(t.replies.first.id, 'r-1');
      expect(t.replies.first.isStaff, isTrue);
    });

    test('defaults replies to empty and nulls optionals on empty json', () {
      final t = SupportTicket.fromJson({});

      expect(t.id, '');
      expect(t.ticketNumber, '');
      expect(t.subject, '');
      expect(t.description, '');
      expect(t.category, '');
      expect(t.priority, '');
      expect(t.status, '');
      expect(t.projectId, isNull);
      expect(t.createdAt, '');
      expect(t.updatedAt, '');
      expect(t.resolvedAt, isNull);
      expect(t.replies, isEmpty);
    });

    test('non-list replies collapses to empty list', () {
      final t = SupportTicket.fromJson({'id': 't-2', 'replies': 'nope'});
      expect(t.replies, isEmpty);
    });
  });
}
