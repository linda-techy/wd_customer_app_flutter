import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_module_models.dart';

/// Pure-parsing tests for every `fromJson` factory in
/// lib/models/project_module_models.dart.
///
/// Each JSON map mirrors the REAL shape returned by the customer API
/// (com.wd.custapi.dto.ProjectModuleDtos). No mocks, no network, no Dio.
void main() {
  group('DocumentCategory.fromJson', () {
    test('parses a fully-populated category', () {
      final json = {
        'id': 3,
        'name': 'Drawings',
        'description': 'Architectural & structural drawings',
        'displayOrder': 2,
      };
      final c = DocumentCategory.fromJson(json);
      expect(c.id, 3);
      expect(c.name, 'Drawings');
      expect(c.description, 'Architectural & structural drawings');
      expect(c.displayOrder, 2);
    });

    test('null displayOrder collapses to 0 and null description stays null', () {
      final json = {
        'id': 9,
        'name': 'Misc',
        'description': null,
        'displayOrder': null,
      };
      final c = DocumentCategory.fromJson(json);
      expect(c.displayOrder, 0);
      expect(c.description, isNull);
    });
  });

  group('ProjectDocument.fromJson', () {
    test('parses a fully-populated document', () {
      final json = {
        'id': 55,
        'projectId': 49,
        'categoryId': 3,
        'categoryName': 'Drawings',
        'filename': 'GF-plan.pdf',
        'filePath': '/storage/docs/49/GF-plan.pdf',
        'downloadUrl': 'https://api.walldot.in/files/GF-plan.pdf',
        'fileSize': 204800,
        'fileType': 'application/pdf',
        'uploadedById': 12,
        'uploadedByName': 'Site Engineer',
        'uploadDate': '2026-04-23T10:00:00',
        'description': 'Ground floor plan',
        'version': 2,
        'isActive': true,
      };
      final d = ProjectDocument.fromJson(json);
      expect(d.id, 55);
      expect(d.projectId, 49);
      expect(d.categoryId, 3);
      expect(d.categoryName, 'Drawings');
      expect(d.filename, 'GF-plan.pdf');
      expect(d.filePath, '/storage/docs/49/GF-plan.pdf');
      expect(d.downloadUrl, 'https://api.walldot.in/files/GF-plan.pdf');
      expect(d.fileSize, 204800);
      expect(d.fileType, 'application/pdf');
      expect(d.uploadedById, 12);
      expect(d.uploadedByName, 'Site Engineer');
      expect(d.uploadDate, DateTime.parse('2026-04-23T10:00:00'));
      expect(d.description, 'Ground floor plan');
      expect(d.version, 2);
      expect(d.isActive, true);
    });

    test('null downloadUrl collapses to empty string; null isActive defaults true', () {
      final json = {
        'id': 56,
        'projectId': 49,
        'categoryId': 3,
        'categoryName': 'Drawings',
        'filename': 'x.pdf',
        'filePath': '/x.pdf',
        'downloadUrl': null,
        'fileSize': null,
        'fileType': null,
        'uploadedById': null,
        'uploadedByName': null,
        'uploadDate': '2026-04-23T10:00:00',
        'description': null,
        'version': 1,
        'isActive': null,
      };
      final d = ProjectDocument.fromJson(json);
      expect(d.downloadUrl, '');
      expect(d.isActive, true);
      expect(d.fileSize, isNull);
      expect(d.fileType, isNull);
      expect(d.uploadedById, isNull);
      expect(d.uploadedByName, isNull);
      expect(d.description, isNull);
    });
  });

  group('QualityCheck.fromJson', () {
    test('parses a fully-populated, resolved QC', () {
      final json = {
        'id': 7,
        'projectId': 49,
        'title': 'Slab curing check',
        'description': 'Verify 7-day curing',
        'sopReference': 'SOP-RCC-04',
        'status': 'RESOLVED',
        'priority': 'HIGH',
        'assignedToId': 12,
        'assignedToName': 'Engineer A',
        'createdById': 5,
        'createdByName': 'Suresh',
        'createdAt': '2026-04-23T10:00:00',
        'resolvedAt': '2026-04-25T12:00:00',
        'resolvedById': 12,
        'resolvedByName': 'Engineer A',
        'resolutionNotes': 'Passed',
      };
      final q = QualityCheck.fromJson(json);
      expect(q.id, 7);
      expect(q.projectId, 49);
      expect(q.title, 'Slab curing check');
      expect(q.description, 'Verify 7-day curing');
      expect(q.sopReference, 'SOP-RCC-04');
      expect(q.status, 'RESOLVED');
      expect(q.priority, 'HIGH');
      expect(q.assignedToId, 12);
      expect(q.assignedToName, 'Engineer A');
      expect(q.createdById, 5);
      expect(q.createdByName, 'Suresh');
      expect(q.createdAt, DateTime.parse('2026-04-23T10:00:00'));
      expect(q.resolvedAt, DateTime.parse('2026-04-25T12:00:00'));
      expect(q.resolvedById, 12);
      expect(q.resolvedByName, 'Engineer A');
      expect(q.resolutionNotes, 'Passed');
    });

    test('null id/projectId/title default to sentinels; status/priority default', () {
      final json = {
        'id': null,
        'projectId': null,
        'title': null,
        'status': null,
        'priority': null,
        'createdById': null,
        'createdByName': null,
        'createdAt': '2026-04-23T10:00:00',
        'resolvedAt': null,
      };
      final q = QualityCheck.fromJson(json);
      expect(q.id, 0);
      expect(q.projectId, 0);
      expect(q.title, '');
      expect(q.status, 'ACTIVE');
      expect(q.priority, 'MEDIUM');
      expect(q.createdById, 0);
      // null/empty createdByName surfaces the construction role
      expect(q.createdByName, 'Site Engineer');
      expect(q.resolvedAt, isNull);
    });

    test('blank/whitespace createdByName falls back to "Site Engineer"', () {
      final json = {
        'id': 1,
        'projectId': 49,
        'title': 'x',
        'status': 'ACTIVE',
        'priority': 'LOW',
        'createdById': 0,
        'createdByName': '   ',
        'createdAt': '2026-04-23T10:00:00',
      };
      final q = QualityCheck.fromJson(json);
      expect(q.createdByName, 'Site Engineer');
    });
  });

  group('ActivityFeed.fromJson', () {
    test('parses a fully-populated activity with metadata', () {
      final json = {
        'id': 100,
        'projectId': 49,
        'activityTypeName': 'Site Report',
        'activityTypeIcon': 'description',
        'activityTypeColor': '#2196F3',
        'title': 'Daily report',
        'description': 'GF slab poured',
        'referenceId': 501,
        'referenceType': 'SITE_REPORT',
        'createdById': 12,
        'createdByName': 'Engineer A',
        'createdAt': '2026-04-23T10:00:00',
        'metadata': {'photos': 4, 'weather': 'sunny'},
      };
      final a = ActivityFeed.fromJson(json);
      expect(a.id, 100);
      expect(a.projectId, 49);
      expect(a.activityTypeName, 'Site Report');
      expect(a.activityTypeIcon, 'description');
      expect(a.activityTypeColor, '#2196F3');
      expect(a.title, 'Daily report');
      expect(a.description, 'GF slab poured');
      expect(a.referenceId, 501);
      expect(a.referenceType, 'SITE_REPORT');
      expect(a.createdById, 12);
      expect(a.createdByName, 'Engineer A');
      expect(a.createdAt, DateTime.parse('2026-04-23T10:00:00'));
      expect(a.metadata, {'photos': 4, 'weather': 'sunny'});
    });

    test('nullable reference + metadata fields stay null', () {
      final json = {
        'id': 101,
        'projectId': 49,
        'activityTypeName': 'Note',
        'activityTypeIcon': 'note',
        'activityTypeColor': '#000',
        'title': 'A note',
        'description': null,
        'referenceId': null,
        'referenceType': null,
        'createdById': 12,
        'createdByName': 'Engineer A',
        'createdAt': '2026-04-23T10:00:00',
        'metadata': null,
      };
      final a = ActivityFeed.fromJson(json);
      expect(a.description, isNull);
      expect(a.referenceId, isNull);
      expect(a.referenceType, isNull);
      expect(a.metadata, isNull);
    });
  });

  group('GalleryImage.fromJson', () {
    test('parses a fully-populated image including tags list', () {
      final json = {
        'id': 200,
        'projectId': 49,
        'imagePath': '/img/200.jpg',
        'thumbnailPath': '/img/thumb/200.jpg',
        'caption': 'GF slab',
        'takenDate': '2026-04-23T09:00:00',
        'uploadedById': 12,
        'uploadedByName': 'Engineer A',
        'uploadedAt': '2026-04-23T10:00:00',
        'siteReportId': 501,
        'locationTag': 'Ground Floor',
        'tags': ['rcc', 'slab', 'gf'],
      };
      final g = GalleryImage.fromJson(json);
      expect(g.id, 200);
      expect(g.projectId, 49);
      expect(g.imagePath, '/img/200.jpg');
      expect(g.thumbnailPath, '/img/thumb/200.jpg');
      expect(g.caption, 'GF slab');
      expect(g.takenDate, DateTime.parse('2026-04-23T09:00:00'));
      expect(g.uploadedById, 12);
      expect(g.uploadedByName, 'Engineer A');
      expect(g.uploadedAt, DateTime.parse('2026-04-23T10:00:00'));
      expect(g.siteReportId, 501);
      expect(g.locationTag, 'Ground Floor');
      expect(g.tags, ['rcc', 'slab', 'gf']);
    });

    test('null tags stays null; other nullables stay null', () {
      final json = {
        'id': 201,
        'projectId': 49,
        'imagePath': '/img/201.jpg',
        'thumbnailPath': null,
        'caption': null,
        'takenDate': '2026-04-23T09:00:00',
        'uploadedById': null,
        'uploadedByName': null,
        'uploadedAt': '2026-04-23T10:00:00',
        'siteReportId': null,
        'locationTag': null,
        'tags': null,
      };
      final g = GalleryImage.fromJson(json);
      expect(g.tags, isNull);
      expect(g.thumbnailPath, isNull);
      expect(g.caption, isNull);
      expect(g.siteReportId, isNull);
    });
  });

  group('Observation.fromJson', () {
    test('parses a fully-populated, resolved observation', () {
      final json = {
        'id': 300,
        'projectId': 49,
        'title': 'Crack in plaster',
        'description': 'Hairline crack near window',
        'reportedById': 12,
        'reportedByName': 'Engineer A',
        'reportedByRoleId': 4,
        'reportedByRoleName': 'Site Engineer',
        'reportedDate': '2026-04-23T10:00:00',
        'status': 'RESOLVED',
        'priority': 'MEDIUM',
        'location': 'GF Bedroom',
        'imagePath': '/img/obs/300.jpg',
        'resolvedDate': '2026-04-25T10:00:00',
        'resolvedById': 12,
        'resolvedByName': 'Engineer A',
        'resolutionNotes': 'Filled & repainted',
      };
      final o = Observation.fromJson(json);
      expect(o.id, 300);
      expect(o.projectId, 49);
      expect(o.title, 'Crack in plaster');
      expect(o.description, 'Hairline crack near window');
      expect(o.reportedById, 12);
      expect(o.reportedByName, 'Engineer A');
      expect(o.reportedByRoleId, 4);
      expect(o.reportedByRoleName, 'Site Engineer');
      expect(o.reportedDate, DateTime.parse('2026-04-23T10:00:00'));
      expect(o.status, 'RESOLVED');
      expect(o.priority, 'MEDIUM');
      expect(o.location, 'GF Bedroom');
      expect(o.imagePath, '/img/obs/300.jpg');
      expect(o.resolvedDate, DateTime.parse('2026-04-25T10:00:00'));
      expect(o.resolvedById, 12);
      expect(o.resolvedByName, 'Engineer A');
      expect(o.resolutionNotes, 'Filled & repainted');
    });

    test('open observation has null resolvedDate and resolution fields', () {
      final json = {
        'id': 301,
        'projectId': 49,
        'title': 'Open issue',
        'description': 'Pending',
        'reportedById': 12,
        'reportedByName': 'Engineer A',
        'reportedByRoleId': null,
        'reportedByRoleName': null,
        'reportedDate': '2026-04-23T10:00:00',
        'status': 'OPEN',
        'priority': 'HIGH',
        'location': null,
        'imagePath': null,
        'resolvedDate': null,
        'resolvedById': null,
        'resolvedByName': null,
        'resolutionNotes': null,
      };
      final o = Observation.fromJson(json);
      expect(o.resolvedDate, isNull);
      expect(o.resolvedById, isNull);
      expect(o.reportedByRoleId, isNull);
      expect(o.location, isNull);
      expect(o.imagePath, isNull);
    });
  });

  group('CctvCamera.fromJson', () {
    test('parses camelCase payload fully', () {
      final json = {
        'id': 400,
        'projectId': 49,
        'cameraName': 'Front Gate',
        'location': 'Entrance',
        'provider': 'Hikvision',
        'streamProtocol': 'HLS',
        'streamUrl': 'https://cctv.walldot.in/400/index.m3u8',
        'snapshotUrl': 'https://cctv.walldot.in/400/snap.jpg',
        'isActive': true,
        'resolution': '1080p',
        'installationDate': '2026-04-01T00:00:00',
      };
      final c = CctvCamera.fromJson(json);
      expect(c.id, 400);
      expect(c.projectId, 49);
      expect(c.cameraName, 'Front Gate');
      expect(c.location, 'Entrance');
      expect(c.provider, 'Hikvision');
      expect(c.streamProtocol, 'HLS');
      expect(c.streamUrl, 'https://cctv.walldot.in/400/index.m3u8');
      expect(c.snapshotUrl, 'https://cctv.walldot.in/400/snap.jpg');
      expect(c.isActive, true);
      expect(c.resolution, '1080p');
      expect(c.installationDate, DateTime.parse('2026-04-01T00:00:00'));
      expect(c.hasStream, true);
    });

    test('parses snake_case fallback keys', () {
      final json = {
        'id': 401,
        'camera_name': 'Back Yard',
        'stream_protocol': 'RTSP',
        'stream_url': 'rtsp://10.0.0.5/live',
        'snapshot_url': 'http://10.0.0.5/snap.jpg',
        'is_active': false,
      };
      final c = CctvCamera.fromJson(json);
      expect(c.cameraName, 'Back Yard');
      expect(c.streamProtocol, 'RTSP');
      expect(c.streamUrl, 'rtsp://10.0.0.5/live');
      expect(c.snapshotUrl, 'http://10.0.0.5/snap.jpg');
      expect(c.isActive, false);
      expect(c.hasStream, true);
    });

    test('null id->0, missing cameraName->empty, isActive defaults true, hasStream false', () {
      final json = <String, dynamic>{
        'id': null,
        'installationDate': null,
      };
      final c = CctvCamera.fromJson(json);
      expect(c.id, 0);
      expect(c.cameraName, '');
      expect(c.isActive, true);
      expect(c.installationDate, isNull);
      expect(c.hasStream, false);
    });

    test('hasStream is false for empty streamUrl', () {
      final c = CctvCamera.fromJson({'id': 1, 'cameraName': 'C', 'streamUrl': ''});
      expect(c.hasStream, false);
    });
  });

  group('View360.fromJson', () {
    test('parses a fully-populated 360 view', () {
      final json = {
        'id': 500,
        'projectId': 49,
        'title': 'GF Living Room',
        'description': '360 capture after plastering',
        'viewUrl': 'https://360.walldot.in/500',
        'thumbnailUrl': 'https://360.walldot.in/500/thumb.jpg',
        'captureDate': '2026-04-20T00:00:00',
        'location': 'Living Room',
        'uploadedById': 12,
        'uploadedByName': 'Engineer A',
        'uploadedAt': '2026-04-20T10:00:00',
        'isActive': true,
        'viewCount': 17,
      };
      final v = View360.fromJson(json);
      expect(v.id, 500);
      expect(v.projectId, 49);
      expect(v.title, 'GF Living Room');
      expect(v.description, '360 capture after plastering');
      expect(v.viewUrl, 'https://360.walldot.in/500');
      expect(v.thumbnailUrl, 'https://360.walldot.in/500/thumb.jpg');
      expect(v.captureDate, DateTime.parse('2026-04-20T00:00:00'));
      expect(v.location, 'Living Room');
      expect(v.uploadedById, 12);
      expect(v.uploadedByName, 'Engineer A');
      expect(v.uploadedAt, DateTime.parse('2026-04-20T10:00:00'));
      expect(v.isActive, true);
      expect(v.viewCount, 17);
    });

    test('null captureDate stays null; isActive defaults true, viewCount defaults 0', () {
      final json = {
        'id': 501,
        'projectId': 49,
        'title': 'View',
        'description': null,
        'viewUrl': 'https://360.walldot.in/501',
        'thumbnailUrl': null,
        'captureDate': null,
        'location': null,
        'uploadedById': null,
        'uploadedByName': null,
        'uploadedAt': '2026-04-20T10:00:00',
        'isActive': null,
        'viewCount': null,
      };
      final v = View360.fromJson(json);
      expect(v.captureDate, isNull);
      expect(v.isActive, true);
      expect(v.viewCount, 0);
    });
  });

  group('SiteVisit.fromJson', () {
    test('parses a fully-populated visit with GPS + attendees', () {
      final json = {
        'id': 600,
        'projectId': 49,
        'visitorId': 12,
        'visitorName': 'Engineer A',
        'visitorRoleId': 4,
        'visitorRoleName': 'Site Engineer',
        'checkInTime': '2026-04-23T09:00:00',
        'checkOutTime': '2026-04-23T11:30:00',
        'purpose': 'Slab inspection',
        'notes': 'All good',
        'findings': 'No defects',
        'location': 'Site',
        'weatherConditions': 'Sunny',
        'attendees': ['Owner', 'Mason'],
        'checkInLatitude': 10.5,
        'checkInLongitude': 76.2,
        'checkOutLatitude': 10.51,
        'checkOutLongitude': 76.21,
        'distanceFromProjectCheckIn': 0.35,
        'distanceFromProjectCheckOut': 1.5,
      };
      final s = SiteVisit.fromJson(json);
      expect(s.id, 600);
      expect(s.projectId, 49);
      expect(s.visitorId, 12);
      expect(s.visitorName, 'Engineer A');
      expect(s.visitorRoleId, 4);
      expect(s.visitorRoleName, 'Site Engineer');
      expect(s.checkInTime, DateTime.parse('2026-04-23T09:00:00'));
      expect(s.checkOutTime, DateTime.parse('2026-04-23T11:30:00'));
      expect(s.purpose, 'Slab inspection');
      expect(s.notes, 'All good');
      expect(s.findings, 'No defects');
      expect(s.location, 'Site');
      expect(s.weatherConditions, 'Sunny');
      expect(s.attendees, ['Owner', 'Mason']);
      expect(s.checkInLatitude, 10.5);
      expect(s.checkInLongitude, 76.2);
      expect(s.checkOutLatitude, 10.51);
      expect(s.checkOutLongitude, 76.21);
      expect(s.distanceFromProjectCheckIn, 0.35);
      expect(s.distanceFromProjectCheckOut, 1.5);
      // computed getters: <1km formats as metres, >=1km as km
      expect(s.formattedCheckInDistance, '350 m');
      expect(s.formattedCheckOutDistance, '1.5 km');
    });

    test('coerces integer lat/long to double (num->double)', () {
      final json = {
        'id': 601,
        'projectId': 49,
        'visitorId': 12,
        'visitorName': 'Engineer A',
        'checkInTime': '2026-04-23T09:00:00',
        'checkInLatitude': 10,
        'checkInLongitude': 76,
        'distanceFromProjectCheckIn': 2,
      };
      final s = SiteVisit.fromJson(json);
      expect(s.checkInLatitude, 10.0);
      expect(s.checkInLatitude, isA<double>());
      expect(s.checkInLongitude, 76.0);
      expect(s.distanceFromProjectCheckIn, 2.0);
    });

    test('null checkout + null GPS: nullables stay null, distance getters null', () {
      final json = {
        'id': 602,
        'projectId': 49,
        'visitorId': 12,
        'visitorName': 'Engineer A',
        'visitorRoleId': null,
        'visitorRoleName': null,
        'checkInTime': '2026-04-23T09:00:00',
        'checkOutTime': null,
        'attendees': null,
        'checkInLatitude': null,
        'distanceFromProjectCheckIn': null,
        'distanceFromProjectCheckOut': null,
      };
      final s = SiteVisit.fromJson(json);
      expect(s.checkOutTime, isNull);
      expect(s.attendees, isNull);
      expect(s.checkInLatitude, isNull);
      expect(s.formattedCheckInDistance, isNull);
      expect(s.formattedCheckOutDistance, isNull);
    });
  });

  group('FeedbackForm.fromJson', () {
    test('parses a fully-populated form', () {
      final json = {
        'id': 700,
        'projectId': 49,
        'title': 'Handover satisfaction',
        'description': 'Rate the handover',
        'formType': 'SATISFACTION',
        'createdById': 5,
        'createdByName': 'Admin',
        'createdAt': '2026-04-23T10:00:00',
        'isActive': true,
        'isCompleted': false,
      };
      final f = FeedbackForm.fromJson(json);
      expect(f.id, 700);
      expect(f.projectId, 49);
      expect(f.title, 'Handover satisfaction');
      expect(f.description, 'Rate the handover');
      expect(f.formType, 'SATISFACTION');
      expect(f.createdById, 5);
      expect(f.createdByName, 'Admin');
      expect(f.createdAt, DateTime.parse('2026-04-23T10:00:00'));
      expect(f.isActive, true);
      expect(f.isCompleted, false);
    });

    test('unattributed form: null id/projectId/title/createdBy default', () {
      final json = {
        'id': null,
        'projectId': null,
        'title': null,
        'description': null,
        'formType': null,
        'createdById': null,
        'createdByName': null,
        'createdAt': '2026-04-23T10:00:00',
        'isActive': null,
        'isCompleted': null,
      };
      final f = FeedbackForm.fromJson(json);
      expect(f.id, 0);
      expect(f.projectId, 0);
      expect(f.title, '');
      expect(f.createdById, 0);
      expect(f.createdByName, '');
      expect(f.isActive, true);
      expect(f.isCompleted, isNull);
    });
  });

  group('FeedbackResponse.fromJson', () {
    test('parses a response with admin reply', () {
      final json = {
        'id': 800,
        'formId': 700,
        'formTitle': 'Handover satisfaction',
        'rating': 5,
        'comments': 'Excellent work',
        'submittedAt': '2026-04-24T10:00:00',
        'isCompleted': true,
        'adminResponse': 'Thank you!',
        'adminRespondedAt': '2026-04-25T09:00:00',
      };
      final r = FeedbackResponse.fromJson(json);
      expect(r.id, 800);
      expect(r.formId, 700);
      expect(r.formTitle, 'Handover satisfaction');
      expect(r.rating, 5);
      expect(r.comments, 'Excellent work');
      expect(r.submittedAt, DateTime.parse('2026-04-24T10:00:00'));
      expect(r.isCompleted, true);
      expect(r.adminResponse, 'Thank you!');
      expect(r.adminRespondedAt, DateTime.parse('2026-04-25T09:00:00'));
    });

    test('no admin reply yet: adminResponse/adminRespondedAt null; null formTitle->empty', () {
      final json = {
        'id': 801,
        'formId': 700,
        'formTitle': null,
        'rating': null,
        'comments': null,
        'submittedAt': '2026-04-24T10:00:00',
        'isCompleted': null,
        'adminResponse': null,
        'adminRespondedAt': null,
      };
      final r = FeedbackResponse.fromJson(json);
      expect(r.formTitle, '');
      expect(r.rating, isNull);
      expect(r.comments, isNull);
      expect(r.isCompleted, isNull);
      expect(r.adminResponse, isNull);
      expect(r.adminRespondedAt, isNull);
    });
  });

  group('BoqWorkType.fromJson', () {
    test('parses a work type', () {
      final json = {
        'id': 7,
        'name': 'RCC Superstructure',
        'description': 'Columns, beams, slabs',
        'displayOrder': 3,
      };
      final w = BoqWorkType.fromJson(json);
      expect(w.id, 7);
      expect(w.name, 'RCC Superstructure');
      expect(w.description, 'Columns, beams, slabs');
      expect(w.displayOrder, 3);
    });

    test('null displayOrder defaults to 0', () {
      final w = BoqWorkType.fromJson({'id': 8, 'name': 'Finishing', 'displayOrder': null});
      expect(w.displayOrder, 0);
      expect(w.description, isNull);
    });
  });

  group('BoqItem.fromJson', () {
    test('parses a fully-populated item with commercials present', () {
      final json = {
        'id': 42,
        'projectId': 49,
        'workTypeId': 7,
        'workTypeName': 'RCC Superstructure',
        'categoryId': 12,
        'categoryName': 'RCC',
        'itemCode': 'RCC-01',
        'description': 'GF slab/beams',
        'quantity': 25.5,
        'unit': 'cum',
        'rate': 8500,
        'amount': 216750,
        'status': 'APPROVED',
        'executedQuantity': 10,
        'billedQuantity': 5,
        'remainingQuantity': 15.5,
        'totalExecutedAmount': 85000,
        'totalBilledAmount': 42500,
        'executionPercentage': 40,
        'billingPercentage': 20,
        'specifications': 'M25 concrete',
        'notes': 'Pour in 2 phases',
        'createdAt': '2026-04-23T10:00:00',
        'updatedAt': '2026-04-24T10:00:00',
        'createdById': 5,
        'createdByName': 'Admin',
        'isActive': true,
        'itemKind': 'BASE',
      };
      final b = BoqItem.fromJson(json);
      expect(b.id, 42);
      expect(b.workTypeId, 7);
      expect(b.workTypeName, 'RCC Superstructure');
      expect(b.categoryId, 12);
      expect(b.itemCode, 'RCC-01');
      expect(b.description, 'GF slab/beams');
      expect(b.quantity, 25.5);
      expect(b.unit, 'cum');
      expect(b.rate, 8500.0);
      expect(b.amount, 216750.0);
      expect(b.status, 'APPROVED');
      expect(b.executedQuantity, 10.0);
      expect(b.billedQuantity, 5.0);
      expect(b.remainingQuantity, 15.5);
      expect(b.totalExecutedAmount, 85000.0);
      expect(b.totalBilledAmount, 42500.0);
      expect(b.executionPercentage, 40.0);
      expect(b.billingPercentage, 20.0);
      expect(b.specifications, 'M25 concrete');
      expect(b.notes, 'Pour in 2 phases');
      expect(b.createdById, 5);
      expect(b.createdByName, 'Admin');
      expect(b.isActive, true);
      expect(b.itemKind, 'BASE');
      expect(b.isAddon, false);
      expect(b.isExclusion, false);
      expect(b.hasProgress, true);
    });

    test('amount falls back to totalAmount key when amount absent', () {
      final json = {
        'id': 43,
        'projectId': 49,
        'description': 'x',
        'totalAmount': 1000,
        'createdAt': '2026-04-23T10:00:00',
        'updatedAt': '2026-04-23T10:00:00',
      };
      final b = BoqItem.fromJson(json);
      expect(b.amount, 1000.0);
    });

    test('redacted commercials stay null; percentages default 0; itemKind defaults BASE', () {
      final json = {
        'id': 44,
        'projectId': 49,
        'workTypeId': null,
        'workTypeName': null,
        'description': null,
        'quantity': null,
        'rate': null,
        'amount': null,
        'executionPercentage': null,
        'billingPercentage': null,
        'createdById': null,
        'createdByName': null,
        'createdAt': '2026-04-23T10:00:00',
        'updatedAt': '2026-04-23T10:00:00',
        'isActive': null,
      };
      final b = BoqItem.fromJson(json);
      expect(b.workTypeId, 0);
      expect(b.workTypeName, '');
      expect(b.description, '');
      expect(b.quantity, isNull);
      expect(b.rate, isNull);
      expect(b.amount, isNull);
      expect(b.executionPercentage, 0.0);
      expect(b.billingPercentage, 0.0);
      expect(b.createdById, 0);
      expect(b.createdByName, '');
      expect(b.isActive, true);
      expect(b.itemKind, 'BASE');
      expect(b.hasProgress, false);
    });

    test('itemKind ADDON / OPTIONAL / EXCLUSION drive getters', () {
      Map<String, dynamic> base(String kind) => {
            'id': 1,
            'projectId': 49,
            'description': 'x',
            'createdAt': '2026-04-23T10:00:00',
            'updatedAt': '2026-04-23T10:00:00',
            'itemKind': kind,
          };
      expect(BoqItem.fromJson(base('ADDON')).isAddon, true);
      expect(BoqItem.fromJson(base('OPTIONAL')).isAddon, true);
      final exclusion = BoqItem.fromJson(base('EXCLUSION'));
      expect(exclusion.isExclusion, true);
      expect(exclusion.isAddon, false);
    });
  });

  group('BoqWorkTypeSummary.fromJson', () {
    test('parses a populated summary', () {
      final json = {
        'workTypeId': 7,
        'workTypeName': 'RCC',
        'subtotal': 500000.5,
        'itemCount': 12,
      };
      final s = BoqWorkTypeSummary.fromJson(json);
      expect(s.workTypeId, 7);
      expect(s.workTypeName, 'RCC');
      expect(s.subtotal, 500000.5);
      expect(s.itemCount, 12);
    });

    test('null fields default to 0/empty', () {
      final s = BoqWorkTypeSummary.fromJson(
          {'workTypeId': null, 'workTypeName': null, 'subtotal': null, 'itemCount': null});
      expect(s.workTypeId, 0);
      expect(s.workTypeName, '');
      expect(s.subtotal, 0.0);
      expect(s.itemCount, 0);
    });
  });

  group('BoqSummary.fromJson', () {
    test('parses a populated summary with nested workTypeSummaries', () {
      final json = {
        'projectId': 49,
        'totalPlannedAmount': 5000000,
        'totalExecutedAmount': 2000000,
        'totalBilledAmount': 1500000,
        'executionPercentage': 40,
        'billingPercentage': 30,
        'totalItems': 50,
        'workTypeSummaries': [
          {'workTypeId': 7, 'workTypeName': 'RCC', 'subtotal': 3000000, 'itemCount': 20},
          {'workTypeId': 8, 'workTypeName': 'Finishing', 'subtotal': 2000000, 'itemCount': 30},
        ],
        'baseScopeAmount': 4500000,
        'addonAmount': 500000,
        'totalValueExGst': 4761904.76,
        'totalValueInclGst': 5000000,
      };
      final s = BoqSummary.fromJson(json);
      expect(s.projectId, 49);
      expect(s.totalPlannedAmount, 5000000.0);
      expect(s.totalExecutedAmount, 2000000.0);
      expect(s.totalBilledAmount, 1500000.0);
      expect(s.executionPercentage, 40.0);
      expect(s.billingPercentage, 30.0);
      expect(s.totalItems, 50);
      expect(s.workTypeSummaries.length, 2);
      expect(s.workTypeSummaries[0].workTypeName, 'RCC');
      expect(s.workTypeSummaries[1].itemCount, 30);
      expect(s.baseScopeAmount, 4500000.0);
      expect(s.addonAmount, 500000.0);
      expect(s.totalValueExGst, 4761904.76);
      expect(s.totalValueInclGst, 5000000.0);
      // computed getters
      expect(s.costToComplete, 3000000.0);
      expect(s.hasAddons, true);
    });

    test('totalPlannedAmount falls back to totalValueInclGst when absent', () {
      final json = {
        'projectId': 49,
        'totalExecutedAmount': 0,
        'totalValueInclGst': 7500000,
        'workTypeSummaries': null,
      };
      final s = BoqSummary.fromJson(json);
      expect(s.totalPlannedAmount, 7500000.0);
      expect(s.totalValueInclGst, 7500000.0);
      // null workTypeSummaries -> empty list (not crash)
      expect(s.workTypeSummaries, isEmpty);
    });

    test('all-null payload yields zero totals, empty list, no addons', () {
      final s = BoqSummary.fromJson(<String, dynamic>{});
      expect(s.projectId, 0);
      expect(s.totalPlannedAmount, 0.0);
      expect(s.totalItems, 0);
      expect(s.workTypeSummaries, isEmpty);
      expect(s.hasAddons, false);
      expect(s.costToComplete, 0.0);
    });
  });

  group('ApiResponse.fromJson', () {
    test('parses with a data mapper applied', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {'id': 7, 'name': 'RCC', 'displayOrder': 1},
      };
      final r = ApiResponse<BoqWorkType>.fromJson(
          json, (d) => BoqWorkType.fromJson(d as Map<String, dynamic>));
      expect(r.success, true);
      expect(r.message, 'OK');
      expect(r.data, isNotNull);
      expect(r.data!.name, 'RCC');
    });

    test('null data yields null even with a mapper', () {
      final json = {'success': false, 'message': 'Not found', 'data': null};
      final r = ApiResponse<BoqWorkType>.fromJson(
          json, (d) => BoqWorkType.fromJson(d as Map<String, dynamic>));
      expect(r.success, false);
      expect(r.message, 'Not found');
      expect(r.data, isNull);
    });

    test('null mapper leaves data null even when present', () {
      final json = {'success': true, 'message': 'OK', 'data': {'x': 1}};
      final r = ApiResponse<dynamic>.fromJson(json, null);
      expect(r.data, isNull);
    });
  });

  group('ProjectWarranty.fromJson', () {
    test('parses an active warranty', () {
      final json = {
        'id': 900,
        'componentName': 'Waterproofing',
        'description': '10-year membrane warranty',
        'providerName': 'Dr. Fixit',
        'startDate': '2026-04-01',
        'endDate': '2036-04-01',
        'status': 'ACTIVE',
        'coverageDetails': 'Roof & basement',
      };
      final w = ProjectWarranty.fromJson(json);
      expect(w.id, 900);
      expect(w.componentName, 'Waterproofing');
      expect(w.description, '10-year membrane warranty');
      expect(w.providerName, 'Dr. Fixit');
      expect(w.startDate, DateTime.parse('2026-04-01'));
      expect(w.endDate, DateTime.parse('2036-04-01'));
      expect(w.status, 'ACTIVE');
      expect(w.coverageDetails, 'Roof & basement');
      expect(w.isActive, true);
      expect(w.isExpired, false);
    });

    test('null status defaults UNKNOWN; null dates stay null; getters reflect status', () {
      final json = {
        'id': 901,
        'componentName': null,
        'startDate': null,
        'endDate': null,
        'status': null,
      };
      final w = ProjectWarranty.fromJson(json);
      expect(w.componentName, '');
      expect(w.startDate, isNull);
      expect(w.endDate, isNull);
      expect(w.status, 'UNKNOWN');
      expect(w.isActive, false);
      expect(w.isExpired, false);
    });

    test('lowercase "expired" status still flags isExpired (case-insensitive)', () {
      final w = ProjectWarranty.fromJson(
          {'id': 1, 'componentName': 'X', 'status': 'expired'});
      expect(w.isExpired, true);
      expect(w.isActive, false);
    });
  });

  group('DelayLog.fromJson', () {
    test('parses an open delay', () {
      final json = {
        'id': 1000,
        'delayType': 'WEATHER',
        'reasonCategory': 'MONSOON',
        'fromDate': '2026-06-01',
        'toDate': null,
        'customerSummary': 'Heavy rain halted RCC',
        'impactOnHandover': 'MINOR',
        'isOpen': true,
        'impactDays': 3,
      };
      final d = DelayLog.fromJson(json);
      expect(d.id, 1000);
      expect(d.delayType, 'WEATHER');
      expect(d.reasonCategory, 'MONSOON');
      expect(d.fromDate, DateTime.parse('2026-06-01'));
      expect(d.toDate, isNull);
      expect(d.customerSummary, 'Heavy rain halted RCC');
      expect(d.impactOnHandover, 'MINOR');
      expect(d.isOpen, true);
      expect(d.impactDays, 3);
    });

    test('closed delay with toDate; null defaults applied', () {
      final json = {
        'id': 1001,
        'delayType': null,
        'reasonCategory': null,
        'fromDate': '2026-05-01',
        'toDate': '2026-05-05',
        'customerSummary': null,
        'impactOnHandover': null,
        'isOpen': null,
        'impactDays': null,
      };
      final d = DelayLog.fromJson(json);
      expect(d.delayType, '');
      expect(d.reasonCategory, isNull);
      expect(d.toDate, DateTime.parse('2026-05-05'));
      expect(d.impactOnHandover, isNull);
      expect(d.isOpen, true); // null isOpen defaults to true
      expect(d.impactDays, 0); // null impactDays defaults to 0
    });

    test('impactDays coerces a double to int', () {
      final json = {
        'id': 1002,
        'delayType': 'MATERIAL',
        'fromDate': '2026-05-01',
        'impactDays': 4.0,
      };
      final d = DelayLog.fromJson(json);
      expect(d.impactDays, 4);
      expect(d.impactDays, isA<int>());
    });
  });

  group('BoqInvoice.fromJson', () {
    test('parses a fully-populated invoice', () {
      final json = {
        'id': 1100,
        'invoiceNumber': 'INV-2026-001',
        'invoiceType': 'PROGRESS',
        'subtotalExGst': 100000,
        'gstRate': 18,
        'gstAmount': 18000,
        'totalInclGst': 118000,
        'totalCreditApplied': 8000,
        'netAmountDue': 110000,
        'status': 'SENT',
        'issueDate': '2026-05-01',
        'dueDate': '2026-05-15',
        'sentAt': '2026-05-01T10:00:00',
        'paidAt': null,
      };
      final i = BoqInvoice.fromJson(json);
      expect(i.id, 1100);
      expect(i.invoiceNumber, 'INV-2026-001');
      expect(i.invoiceType, 'PROGRESS');
      expect(i.subtotalExGst, 100000.0);
      expect(i.gstRate, 18.0);
      expect(i.gstAmount, 18000.0);
      expect(i.totalInclGst, 118000.0);
      expect(i.totalCreditApplied, 8000.0);
      expect(i.netAmountDue, 110000.0);
      expect(i.status, 'SENT');
      expect(i.issueDate, DateTime.parse('2026-05-01'));
      expect(i.dueDate, DateTime.parse('2026-05-15'));
      expect(i.sentAt, DateTime.parse('2026-05-01T10:00:00'));
      expect(i.paidAt, isNull);
    });

    test('parses numeric strings via double.tryParse fallback', () {
      final json = {
        'id': 1101,
        'subtotalExGst': '100000.50',
        'gstRate': '18',
        'gstAmount': 'not-a-number',
        'totalInclGst': null,
        'totalCreditApplied': '0',
        'netAmountDue': '118000.50',
        'status': null,
      };
      final i = BoqInvoice.fromJson(json);
      expect(i.subtotalExGst, 100000.50);
      expect(i.gstRate, 18.0);
      expect(i.gstAmount, 0.0); // unparseable string -> 0.0
      expect(i.totalInclGst, 0.0); // null -> 0.0
      expect(i.netAmountDue, 118000.50);
      expect(i.status, 'UNKNOWN'); // null status default
    });

    test('null dates stay null', () {
      final json = {
        'id': 1102,
        'subtotalExGst': 0,
        'gstRate': 0,
        'gstAmount': 0,
        'totalInclGst': 0,
        'totalCreditApplied': 0,
        'netAmountDue': 0,
        'status': 'DRAFT',
        'issueDate': null,
        'dueDate': null,
        'sentAt': null,
        'paidAt': null,
      };
      final i = BoqInvoice.fromJson(json);
      expect(i.issueDate, isNull);
      expect(i.dueDate, isNull);
      expect(i.sentAt, isNull);
      expect(i.paidAt, isNull);
    });
  });

  group('CombinedActivityItem.fromJson', () {
    test('parses a site report item', () {
      final json = {
        'id': 1200,
        'type': 'SITE_REPORT',
        'title': 'Daily report',
        'description': 'GF slab poured',
        'timestamp': '2026-04-23T10:00:00',
        'date': '2026-04-23T00:00:00',
        'status': 'SUBMITTED',
        'createdByName': 'Engineer A',
        'metadata': {'photos': 4},
      };
      final c = CombinedActivityItem.fromJson(json);
      expect(c.id, 1200);
      expect(c.type, 'SITE_REPORT');
      expect(c.title, 'Daily report');
      expect(c.description, 'GF slab poured');
      expect(c.timestamp, DateTime.parse('2026-04-23T10:00:00'));
      expect(c.date, DateTime.parse('2026-04-23T00:00:00'));
      expect(c.status, 'SUBMITTED');
      expect(c.createdByName, 'Engineer A');
      expect(c.metadata, {'photos': 4});
      expect(c.isSiteReport, true);
    });

    test('non-site-report type + null optionals', () {
      final json = {
        'id': 1201,
        'type': 'OBSERVATION',
        'title': 'Crack noted',
        'description': null,
        'timestamp': '2026-04-23T10:00:00',
        'date': '2026-04-23T00:00:00',
        'status': null,
        'createdByName': 'Engineer A',
        'metadata': null,
      };
      final c = CombinedActivityItem.fromJson(json);
      expect(c.description, isNull);
      expect(c.status, isNull);
      expect(c.metadata, isNull);
      expect(c.isSiteReport, false);
    });
  });
}
