import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_models.dart';

void main() {
  group('Project.fromJson', () {
    // Mirrors the shape consumed by the customer home/project-detail screens.
    test('parses a full happy-path payload', () {
      final json = {
        'id': 'PRJ-2026-0049',
        'name': 'Kerala G+1 Residence',
        'location': 'Kakkanad',
        'city': 'Kochi',
        'area': '2400 sqft',
        'status': 'ACTIVE',
        'progress': 45.5,
        'nextMilestone': 'Plastering',
        'nextMilestoneDate': '2026-06-15T00:00:00',
        'thumbnailUrl': 'https://cdn.example.com/p49.jpg',
        'lastUpdate': 'Roof slab cast',
        'lastUpdatedAt': '2026-05-30T10:00:00',
        'totalBudget': 3500000.0,
        'paidAmount': 1400000.0,
        'dueAmount': 2100000.0,
        'qcCompleted': 12,
        'qcPending': 3,
        'activeQueries': 2,
        'galleryPhotos': 48,
        'details': {
          'description': 'Two-storey residential build',
          'startDate': '2026-01-01T00:00:00',
          'expectedEndDate': '2026-12-31T00:00:00',
          'contractor': 'WallDot Constructions',
          'architect': 'Jane Doe',
          'progressBreakdown': {'foundation': 100.0, 'rcc': 60.0},
          'milestones': ['Foundation', 'RCC', 'Plastering'],
        },
      };

      final p = Project.fromJson(json);

      expect(p.id, 'PRJ-2026-0049');
      expect(p.name, 'Kerala G+1 Residence');
      expect(p.location, 'Kakkanad');
      expect(p.city, 'Kochi');
      expect(p.area, '2400 sqft');
      expect(p.status, ProjectStatus.active);
      expect(p.progress, 45.5);
      expect(p.nextMilestone, 'Plastering');
      expect(p.nextMilestoneDate, DateTime(2026, 6, 15));
      expect(p.thumbnailUrl, 'https://cdn.example.com/p49.jpg');
      expect(p.lastUpdate, 'Roof slab cast');
      expect(p.lastUpdatedAt, DateTime(2026, 5, 30, 10));
      expect(p.totalBudget, 3500000.0);
      expect(p.paidAmount, 1400000.0);
      expect(p.dueAmount, 2100000.0);
      expect(p.qcCompleted, 12);
      expect(p.qcPending, 3);
      expect(p.activeQueries, 2);
      expect(p.galleryPhotos, 48);
      expect(p.details, isA<ProjectDetails>());
      expect(p.details.contractor, 'WallDot Constructions');
    });

    test('coerces int-shaped numerics into double for money/progress', () {
      final json = _baseProjectJson(
        progress: 50, // int, not double
        totalBudget: 3500000, // int
        paidAmount: 0, // int
        dueAmount: 3500000, // int
      );

      final p = Project.fromJson(json);

      expect(p.progress, 50.0);
      expect(p.totalBudget, 3500000.0);
      expect(p.paidAmount, 0.0);
      expect(p.dueAmount, 3500000.0);
    });

    test('maps each known status string to its enum', () {
      expect(Project.fromJson(_baseProjectJson(status: 'ACTIVE')).status,
          ProjectStatus.active);
      expect(Project.fromJson(_baseProjectJson(status: 'COMPLETED')).status,
          ProjectStatus.completed);
      expect(Project.fromJson(_baseProjectJson(status: 'SUSPENDED')).status,
          ProjectStatus.suspended);
      expect(Project.fromJson(_baseProjectJson(status: 'CANCELLED')).status,
          ProjectStatus.cancelled);
      expect(Project.fromJson(_baseProjectJson(status: 'ON_HOLD')).status,
          ProjectStatus.onHold);
    });

    test('status parsing is case-insensitive', () {
      expect(Project.fromJson(_baseProjectJson(status: 'active')).status,
          ProjectStatus.active);
      expect(Project.fromJson(_baseProjectJson(status: 'on_hold')).status,
          ProjectStatus.onHold);
    });

    test('null or unknown status defaults to active', () {
      expect(Project.fromJson(_baseProjectJson(status: null)).status,
          ProjectStatus.active);
      expect(Project.fromJson(_baseProjectJson(status: 'GIBBERISH')).status,
          ProjectStatus.active);
    });
  });

  group('ProjectDetails.fromJson', () {
    test('parses nested maps and lists', () {
      final json = {
        'description': 'Two-storey residential build',
        'startDate': '2026-01-01T00:00:00',
        'expectedEndDate': '2026-12-31T00:00:00',
        'contractor': 'WallDot Constructions',
        'architect': 'Jane Doe',
        'progressBreakdown': {'foundation': 100.0, 'rcc': 60.5},
        'milestones': ['Foundation', 'RCC', 'Plastering'],
      };

      final d = ProjectDetails.fromJson(json);

      expect(d.description, 'Two-storey residential build');
      expect(d.startDate, DateTime(2026, 1, 1));
      expect(d.expectedEndDate, DateTime(2026, 12, 31));
      expect(d.contractor, 'WallDot Constructions');
      expect(d.architect, 'Jane Doe');
      expect(d.progressBreakdown['foundation'], 100.0);
      expect(d.progressBreakdown['rcc'], 60.5);
      expect(d.milestones, ['Foundation', 'RCC', 'Plastering']);
    });

    test('tolerates empty breakdown and milestones', () {
      final json = {
        'description': '',
        'startDate': '2026-01-01T00:00:00',
        'expectedEndDate': '2026-12-31T00:00:00',
        'contractor': '',
        'architect': '',
        'progressBreakdown': <String, double>{},
        'milestones': <String>[],
      };

      final d = ProjectDetails.fromJson(json);

      expect(d.progressBreakdown, isEmpty);
      expect(d.milestones, isEmpty);
    });
  });

  group('Document.fromJson', () {
    test('parses a full payload and maps known type', () {
      final json = {
        'id': 'DOC-1',
        'name': 'Ground Floor Plan',
        'type': 'floorPlan',
        'uploadedBy': 'Architect',
        'uploadDate': '2026-02-01T09:00:00',
        'version': 'v2',
        'url': 'https://cdn.example.com/doc1.pdf',
        'thumbnailUrl': 'https://cdn.example.com/doc1_thumb.jpg',
        'fileSize': 204800,
        'description': 'Stamped floor plan',
      };

      final d = Document.fromJson(json);

      expect(d.id, 'DOC-1');
      expect(d.name, 'Ground Floor Plan');
      expect(d.type, DocumentType.floorPlan);
      expect(d.uploadedBy, 'Architect');
      expect(d.uploadDate, DateTime(2026, 2, 1, 9));
      expect(d.version, 'v2');
      expect(d.url, 'https://cdn.example.com/doc1.pdf');
      expect(d.thumbnailUrl, 'https://cdn.example.com/doc1_thumb.jpg');
      expect(d.fileSize, 204800);
      expect(d.description, 'Stamped floor plan');
    });

    test('unknown type falls back to other', () {
      final json = _baseDocumentJson(type: 'mysteryType');
      expect(Document.fromJson(json).type, DocumentType.other);
    });

    test('maps each known document type', () {
      expect(Document.fromJson(_baseDocumentJson(type: 'structural')).type,
          DocumentType.structural);
      expect(Document.fromJson(_baseDocumentJson(type: 'electrical')).type,
          DocumentType.electrical);
      expect(Document.fromJson(_baseDocumentJson(type: 'plumbing')).type,
          DocumentType.plumbing);
      expect(Document.fromJson(_baseDocumentJson(type: 'other')).type,
          DocumentType.other);
    });
  });

  group('QCItem.fromJson', () {
    test('parses a completed item with completedAt', () {
      final json = {
        'id': 'QC-1',
        'title': 'Foundation depth check',
        'description': 'Verify footing depth',
        'status': 'completed',
        'dueDate': '2026-03-01T00:00:00',
        'assignedTo': 'Site Engineer',
        'photos': ['p1.jpg', 'p2.jpg'],
        'comments': 'All good',
        'correctiveActions': ['none'],
        'createdAt': '2026-02-20T08:00:00',
        'completedAt': '2026-02-28T17:00:00',
      };

      final q = QCItem.fromJson(json);

      expect(q.id, 'QC-1');
      expect(q.title, 'Foundation depth check');
      expect(q.description, 'Verify footing depth');
      expect(q.status, QCStatus.completed);
      expect(q.dueDate, DateTime(2026, 3, 1));
      expect(q.assignedTo, 'Site Engineer');
      expect(q.photos, ['p1.jpg', 'p2.jpg']);
      expect(q.comments, 'All good');
      expect(q.correctiveActions, ['none']);
      expect(q.createdAt, DateTime(2026, 2, 20, 8));
      expect(q.completedAt, DateTime(2026, 2, 28, 17));
    });

    test('null completedAt stays null (item not yet done)', () {
      final json = _baseQcJson(status: 'pending');
      json['completedAt'] = null;

      final q = QCItem.fromJson(json);

      expect(q.status, QCStatus.pending);
      expect(q.completedAt, isNull);
    });

    test('unknown status falls back to pending', () {
      expect(QCItem.fromJson(_baseQcJson(status: 'weirdStatus')).status,
          QCStatus.pending);
    });

    test('maps each known QC status', () {
      expect(QCItem.fromJson(_baseQcJson(status: 'pending')).status,
          QCStatus.pending);
      expect(QCItem.fromJson(_baseQcJson(status: 'completed')).status,
          QCStatus.completed);
      expect(QCItem.fromJson(_baseQcJson(status: 'failed')).status,
          QCStatus.failed);
      expect(QCItem.fromJson(_baseQcJson(status: 'inProgress')).status,
          QCStatus.inProgress);
    });
  });

  group('ProjectActivity.fromJson', () {
    test('parses a full payload with imageUrl and metadata', () {
      final json = {
        'id': 'ACT-1',
        'title': 'Slab cast',
        'description': 'First floor slab poured',
        'timestamp': '2026-05-30T11:30:00',
        'type': 'PROGRESS',
        'user': 'Site Engineer',
        'imageUrl': 'https://cdn.example.com/act1.jpg',
        'metadata': {'percent': 60, 'phase': 'RCC'},
      };

      final a = ProjectActivity.fromJson(json);

      expect(a.id, 'ACT-1');
      expect(a.title, 'Slab cast');
      expect(a.description, 'First floor slab poured');
      expect(a.timestamp, DateTime(2026, 5, 30, 11, 30));
      expect(a.type, 'PROGRESS');
      expect(a.user, 'Site Engineer');
      expect(a.imageUrl, 'https://cdn.example.com/act1.jpg');
      expect(a.metadata['percent'], 60);
      expect(a.metadata['phase'], 'RCC');
    });

    test('null imageUrl stays null; empty metadata tolerated', () {
      final json = {
        'id': 'ACT-2',
        'title': 'Comment added',
        'description': 'Customer query logged',
        'timestamp': '2026-05-30T12:00:00',
        'type': 'QUERY',
        'user': 'Customer',
        'imageUrl': null,
        'metadata': <String, dynamic>{},
      };

      final a = ProjectActivity.fromJson(json);

      expect(a.imageUrl, isNull);
      expect(a.metadata, isEmpty);
    });
  });

  group('Payment.fromJson', () {
    test('parses a paid invoice with paidDate', () {
      final json = {
        'id': 'PAY-1',
        'invoiceNumber': 'INV-2026-001',
        'amount': 425000.0,
        'paidAmount': 425000.0,
        'dueDate': '2026-05-15T00:00:00',
        'paidDate': '2026-05-14T00:00:00',
        'status': 'PAID',
        'description': 'Plastering installment',
        'downloadUrl': 'https://cdn.example.com/inv1.pdf',
      };

      final pay = Payment.fromJson(json);

      expect(pay.id, 'PAY-1');
      expect(pay.invoiceNumber, 'INV-2026-001');
      expect(pay.amount, 425000.0);
      expect(pay.paidAmount, 425000.0);
      expect(pay.dueDate, DateTime(2026, 5, 15));
      expect(pay.paidDate, DateTime(2026, 5, 14));
      expect(pay.status, 'PAID');
      expect(pay.description, 'Plastering installment');
      expect(pay.downloadUrl, 'https://cdn.example.com/inv1.pdf');
    });

    test('null paidDate stays null; int amounts coerce to double', () {
      final json = {
        'id': 'PAY-2',
        'invoiceNumber': 'INV-2026-002',
        'amount': 250000, // int
        'paidAmount': 0, // int
        'dueDate': '2026-06-15T00:00:00',
        'paidDate': null,
        'status': 'PENDING',
        'description': 'Foundation installment',
        'downloadUrl': '',
      };

      final pay = Payment.fromJson(json);

      expect(pay.amount, 250000.0);
      expect(pay.paidAmount, 0.0);
      expect(pay.paidDate, isNull);
      expect(pay.status, 'PENDING');
    });
  });

  group('GalleryPhoto.fromJson', () {
    test('parses a full payload', () {
      final json = {
        'id': 'IMG-1',
        'url': 'https://cdn.example.com/img1.jpg',
        'thumbnailUrl': 'https://cdn.example.com/img1_t.jpg',
        'caption': 'Front elevation',
        'uploadedAt': '2026-05-29T15:00:00',
        'uploadedBy': 'Site Engineer',
        'category': 'EXTERIOR',
      };

      final g = GalleryPhoto.fromJson(json);

      expect(g.id, 'IMG-1');
      expect(g.url, 'https://cdn.example.com/img1.jpg');
      expect(g.thumbnailUrl, 'https://cdn.example.com/img1_t.jpg');
      expect(g.caption, 'Front elevation');
      expect(g.uploadedAt, DateTime(2026, 5, 29, 15));
      expect(g.uploadedBy, 'Site Engineer');
      expect(g.category, 'EXTERIOR');
    });
  });

  group('SurveillanceCamera.fromJson', () {
    test('parses an online camera', () {
      final json = {
        'id': 'CAM-1',
        'name': 'Gate Camera',
        'location': 'Main entrance',
        'snapshotUrl': 'https://cdn.example.com/cam1.jpg',
        'streamUrl': 'https://cdn.example.com/cam1.m3u8',
        'isOnline': true,
        'lastUpdated': '2026-05-31T09:00:00',
      };

      final c = SurveillanceCamera.fromJson(json);

      expect(c.id, 'CAM-1');
      expect(c.name, 'Gate Camera');
      expect(c.location, 'Main entrance');
      expect(c.snapshotUrl, 'https://cdn.example.com/cam1.jpg');
      expect(c.streamUrl, 'https://cdn.example.com/cam1.m3u8');
      expect(c.isOnline, isTrue);
      expect(c.lastUpdated, DateTime(2026, 5, 31, 9));
    });

    test('parses an offline camera', () {
      final json = {
        'id': 'CAM-2',
        'name': 'Rear Camera',
        'location': 'Backyard',
        'snapshotUrl': '',
        'streamUrl': '',
        'isOnline': false,
        'lastUpdated': '2026-05-31T09:00:00',
      };

      expect(SurveillanceCamera.fromJson(json).isOnline, isFalse);
    });
  });

  group('ProgressDataPoint.fromJson', () {
    test('parses a double progress value', () {
      final json = {'date': '2026-05-30T00:00:00', 'progress': 45.5};
      final pt = ProgressDataPoint.fromJson(json);
      expect(pt.date, DateTime(2026, 5, 30));
      expect(pt.progress, 45.5);
    });

    test('coerces int progress to double', () {
      final json = {'date': '2026-05-30T00:00:00', 'progress': 45};
      expect(ProgressDataPoint.fromJson(json).progress, 45.0);
    });
  });
}

// ---- Helpers: build minimal valid JSON, overriding only what a test cares about.

Map<String, dynamic> _baseProjectJson({
  Object? status = 'ACTIVE',
  num progress = 10.0,
  num totalBudget = 1000000.0,
  num paidAmount = 0.0,
  num dueAmount = 1000000.0,
}) {
  return {
    'id': 'PRJ-X',
    'name': 'Test Project',
    'location': 'Loc',
    'city': 'City',
    'area': '1000 sqft',
    'status': status,
    'progress': progress,
    'nextMilestone': 'Milestone',
    'nextMilestoneDate': '2026-06-15T00:00:00',
    'thumbnailUrl': '',
    'lastUpdate': 'update',
    'lastUpdatedAt': '2026-05-30T10:00:00',
    'totalBudget': totalBudget,
    'paidAmount': paidAmount,
    'dueAmount': dueAmount,
    'qcCompleted': 0,
    'qcPending': 0,
    'activeQueries': 0,
    'galleryPhotos': 0,
    'details': {
      'description': 'desc',
      'startDate': '2026-01-01T00:00:00',
      'expectedEndDate': '2026-12-31T00:00:00',
      'contractor': 'c',
      'architect': 'a',
      'progressBreakdown': <String, double>{},
      'milestones': <String>[],
    },
  };
}

Map<String, dynamic> _baseDocumentJson({required String type}) {
  return {
    'id': 'DOC-X',
    'name': 'Doc',
    'type': type,
    'uploadedBy': 'someone',
    'uploadDate': '2026-02-01T09:00:00',
    'version': 'v1',
    'url': '',
    'thumbnailUrl': '',
    'fileSize': 1024,
    'description': '',
  };
}

Map<String, dynamic> _baseQcJson({required String status}) {
  return {
    'id': 'QC-X',
    'title': 'Check',
    'description': 'desc',
    'status': status,
    'dueDate': '2026-03-01T00:00:00',
    'assignedTo': 'eng',
    'photos': <String>[],
    'comments': '',
    'correctiveActions': <String>[],
    'createdAt': '2026-02-20T08:00:00',
    'completedAt': null,
  };
}
