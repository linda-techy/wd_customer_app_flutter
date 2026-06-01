import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/api_models.dart';

/// Pure parsing tests for every `fromJson` factory in lib/models/api_models.dart.
/// No mocks, no network — only real-API-shaped JSON maps fed straight into the
/// factories. Assertions mirror the ACTUAL parsing/defaulting logic in source.
void main() {
  group('UserInfo.fromJson', () {
    test('parses a fully-populated customer user', () {
      final json = {
        'id': 24,
        'email': 'demowalldot@gmail.com',
        'firstName': 'Demo',
        'lastName': 'Customer',
        'role': 'CUSTOMER',
        'phone': '9876543210',
        'whatsappNumber': '9876543210',
        'address': 'Kochi, Kerala',
        'companyName': 'Walldot',
        'gstNumber': '32ABCDE1234F1Z5',
        'customerType': 'business',
      };

      final user = UserInfo.fromJson(json);

      expect(user.id, 24);
      expect(user.email, 'demowalldot@gmail.com');
      expect(user.firstName, 'Demo');
      expect(user.lastName, 'Customer');
      expect(user.role, 'CUSTOMER');
      expect(user.phone, '9876543210');
      expect(user.whatsappNumber, '9876543210');
      expect(user.address, 'Kochi, Kerala');
      expect(user.companyName, 'Walldot');
      expect(user.gstNumber, '32ABCDE1234F1Z5');
      expect(user.customerType, 'business');
      expect(user.fullName, 'Demo Customer');
    });

    test('applies defaults for missing/null fields', () {
      final user = UserInfo.fromJson({});

      expect(user.id, 0);
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.role, '');
      expect(user.phone, '');
      expect(user.whatsappNumber, '');
      expect(user.address, '');
      expect(user.companyName, '');
      expect(user.gstNumber, '');
      // customerType falls back to the 'individual' sentinel
      expect(user.customerType, 'individual');
      // fullName trims away the empty space between empty names
      expect(user.fullName, '');
    });
  });

  group('LoginResponse.fromJson', () {
    test('parses a real login response with nested user + permissions', () {
      final json = {
        'accessToken': 'eyJhbGciOi.token.aaa',
        'refreshToken': 'eyJhbGciOi.refresh.bbb',
        'tokenType': 'Bearer',
        'expiresIn': 3600,
        'user': {
          'id': 24,
          'email': 'demowalldot@gmail.com',
          'firstName': 'Demo',
          'lastName': 'Customer',
          'role': 'CUSTOMER',
        },
        'permissions': ['VIEW_PROJECT', 'VIEW_BILLS'],
        'projectCount': 1,
        'redirectUrl': '/projects',
      };

      final res = LoginResponse.fromJson(json);

      expect(res.accessToken, 'eyJhbGciOi.token.aaa');
      expect(res.refreshToken, 'eyJhbGciOi.refresh.bbb');
      expect(res.tokenType, 'Bearer');
      expect(res.expiresIn, 3600);
      expect(res.user.id, 24);
      expect(res.user.email, 'demowalldot@gmail.com');
      expect(res.permissions, ['VIEW_PROJECT', 'VIEW_BILLS']);
      expect(res.projectCount, 1);
      expect(res.redirectUrl, '/projects');
    });

    test('applies defaults when fields/user/permissions are missing', () {
      final res = LoginResponse.fromJson({});

      expect(res.accessToken, '');
      expect(res.refreshToken, '');
      // tokenType defaults to Bearer
      expect(res.tokenType, 'Bearer');
      expect(res.expiresIn, 0);
      // user built from empty map -> UserInfo defaults
      expect(res.user.id, 0);
      expect(res.user.email, '');
      expect(res.permissions, isEmpty);
      expect(res.projectCount, 0);
      // redirectUrl defaults to /dashboard
      expect(res.redirectUrl, '/dashboard');
    });
  });

  group('RefreshTokenResponse.fromJson', () {
    test('parses a token refresh payload', () {
      final res = RefreshTokenResponse.fromJson({
        'accessToken': 'new.access.token',
        'tokenType': 'Bearer',
        'expiresIn': 7200,
      });

      expect(res.accessToken, 'new.access.token');
      expect(res.tokenType, 'Bearer');
      expect(res.expiresIn, 7200);
    });

    test('applies defaults for empty payload', () {
      final res = RefreshTokenResponse.fromJson({});

      expect(res.accessToken, '');
      expect(res.tokenType, 'Bearer');
      expect(res.expiresIn, 0);
    });
  });

  group('ApiError.fromJson', () {
    test('parses an error with message + status', () {
      final err = ApiError.fromJson({
        'message': 'Project not found',
        'status': 404,
        'error': 'Not Found',
      });

      expect(err.message, 'Project not found');
      // statusCode reads json['status'] first
      expect(err.statusCode, 404);
      expect(err.error, 'Not Found');
      expect(err.toString(), 'ApiError: Project not found (Status: 404)');
    });

    test('falls back to error field for message and statusCode key', () {
      final err = ApiError.fromJson({
        'error': 'Unauthorized',
        'statusCode': 401,
      });

      // message falls back to json['error']
      expect(err.message, 'Unauthorized');
      // statusCode falls back to json['statusCode'] when status absent
      expect(err.statusCode, 401);
      expect(err.error, 'Unauthorized');
    });

    test('uses Unknown error and null status when empty', () {
      final err = ApiError.fromJson({});

      expect(err.message, 'Unknown error');
      expect(err.statusCode, isNull);
      expect(err.error, isNull);
      // toString omits the status segment when statusCode is null
      expect(err.toString(), 'ApiError: Unknown error');
    });
  });

  group('UserSummary.fromJson', () {
    test('parses a dashboard user summary', () {
      final user = UserSummary.fromJson({
        'id': 24,
        'email': 'demo@walldot.in',
        'firstName': 'Demo',
        'lastName': 'Customer',
        'role': 'CUSTOMER',
      });

      expect(user.id, 24);
      expect(user.email, 'demo@walldot.in');
      expect(user.firstName, 'Demo');
      expect(user.lastName, 'Customer');
      expect(user.role, 'CUSTOMER');
      expect(user.fullName, 'Demo Customer');
    });

    test('applies defaults for empty payload', () {
      final user = UserSummary.fromJson({});

      expect(user.id, 0);
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.role, '');
      expect(user.fullName, '');
    });
  });

  group('QuickStats.fromJson', () {
    test('parses quick stats with int + double coercion', () {
      final stats = QuickStats.fromJson({
        'totalBills': 10,
        'pendingBills': 3,
        'paidBills': 7,
        'totalAmount': 1500000.50,
        'pendingAmount': 250000,
      });

      expect(stats.totalBills, 10);
      expect(stats.pendingBills, 3);
      expect(stats.paidBills, 7);
      expect(stats.totalAmount, 1500000.50);
      // int amount coerced to double
      expect(stats.pendingAmount, 250000.0);
      expect(stats.pendingAmount, isA<double>());
    });

    test('applies zero defaults for empty payload', () {
      final stats = QuickStats.fromJson({});

      expect(stats.totalBills, 0);
      expect(stats.pendingBills, 0);
      expect(stats.paidBills, 0);
      expect(stats.totalAmount, 0.0);
      expect(stats.pendingAmount, 0.0);
    });
  });

  group('RecentActivity.fromJson', () {
    test('parses a recent activity entry', () {
      final activity = RecentActivity.fromJson({
        'type': 'PAYMENT',
        'description': 'Milestone payment received',
        'timestamp': '2026-05-10T09:30:00',
        'projectId': 49,
        'projectName': 'Demo Villa',
      });

      expect(activity.type, 'PAYMENT');
      expect(activity.description, 'Milestone payment received');
      expect(activity.timestamp, '2026-05-10T09:30:00');
      expect(activity.projectId, 49);
      expect(activity.projectName, 'Demo Villa');
    });

    test('applies defaults for empty payload', () {
      final activity = RecentActivity.fromJson({});

      expect(activity.type, '');
      expect(activity.description, '');
      expect(activity.timestamp, '');
      expect(activity.projectId, 0);
      expect(activity.projectName, '');
    });
  });

  group('ProjectCard.fromJson', () {
    test('parses a fully-populated project card', () {
      final json = {
        'id': 49,
        'projectUuid': '6043e82e-aaaa-bbbb-cccc-dddddddddddd',
        'name': 'Demo Villa G+1',
        'code': 'PRJ-2026-0049',
        'location': 'Kochi',
        'startDate': '2026-01-01',
        'endDate': '2026-12-31',
        'status': 'CONSTRUCTION',
        'progress': 42.5,
        'projectPhase': 'SUPERSTRUCTURE',
        'projectType': 'NEW_BUILD',
        'designPackage': 'PREMIUM',
        'isDesignAgreementSigned': true,
        'designProgress': 100,
      };

      final card = ProjectCard.fromJson(json);

      expect(card.id, 49);
      expect(card.projectUuid, '6043e82e-aaaa-bbbb-cccc-dddddddddddd');
      expect(card.name, 'Demo Villa G+1');
      expect(card.code, 'PRJ-2026-0049');
      expect(card.location, 'Kochi');
      expect(card.startDate, '2026-01-01');
      expect(card.endDate, '2026-12-31');
      expect(card.status, 'CONSTRUCTION');
      expect(card.progress, 42.5);
      expect(card.projectPhase, 'SUPERSTRUCTURE');
      expect(card.projectType, 'NEW_BUILD');
      expect(card.designPackage, 'PREMIUM');
      expect(card.isDesignAgreementSigned, true);
      // int designProgress coerced to double
      expect(card.designProgress, 100.0);
      expect(card.designProgress, isA<double>());
    });

    test('applies defaults and keeps nullable fields null', () {
      final card = ProjectCard.fromJson({'id': 7, 'name': 'Minimal'});

      expect(card.id, 7);
      expect(card.name, 'Minimal');
      expect(card.projectUuid, isNull);
      expect(card.code, isNull);
      expect(card.location, isNull);
      expect(card.startDate, isNull);
      expect(card.endDate, isNull);
      expect(card.status, isNull);
      // progress defaults to 0 coerced to double
      expect(card.progress, 0.0);
      expect(card.projectPhase, isNull);
      expect(card.projectType, isNull);
      expect(card.designPackage, isNull);
      expect(card.isDesignAgreementSigned, false);
      expect(card.designProgress, 0.0);
    });
  });

  group('ProjectSummary.fromJson', () {
    test('parses summary with nested recentProjects list', () {
      final json = {
        'totalProjects': 3,
        'activeProjects': 2,
        'completedProjects': 1,
        'recentProjects': [
          {'id': 49, 'name': 'Villa A', 'progress': 30},
          {'id': 50, 'name': 'Villa B', 'progress': 60.5},
        ],
      };

      final summary = ProjectSummary.fromJson(json);

      expect(summary.totalProjects, 3);
      expect(summary.activeProjects, 2);
      expect(summary.completedProjects, 1);
      expect(summary.recentProjects, hasLength(2));
      expect(summary.recentProjects[0].id, 49);
      expect(summary.recentProjects[0].name, 'Villa A');
      expect(summary.recentProjects[0].progress, 30.0);
      expect(summary.recentProjects[1].progress, 60.5);
    });

    test('defaults to empty list when recentProjects missing', () {
      final summary = ProjectSummary.fromJson({});

      expect(summary.totalProjects, 0);
      expect(summary.activeProjects, 0);
      expect(summary.completedProjects, 0);
      expect(summary.recentProjects, isEmpty);
    });
  });

  group('ProgressMilestone.fromJson', () {
    test('parses milestone with dates and percentage', () {
      final m = ProgressMilestone.fromJson({
        'name': 'Foundation',
        'progressPercentage': 75.5,
        'targetDate': '2026-03-01T00:00:00',
        'completedDate': '2026-02-28T00:00:00',
        'status': 'COMPLETED',
      });

      expect(m.name, 'Foundation');
      expect(m.progressPercentage, 75.5);
      expect(m.targetDate, DateTime.parse('2026-03-01T00:00:00'));
      expect(m.completedDate, DateTime.parse('2026-02-28T00:00:00'));
      expect(m.status, 'COMPLETED');
    });

    test('applies defaults and keeps dates null when absent', () {
      final m = ProgressMilestone.fromJson({});

      expect(m.name, '');
      // progressPercentage defaults to 0.0 (null-coerced)
      expect(m.progressPercentage, 0.0);
      expect(m.targetDate, isNull);
      expect(m.completedDate, isNull);
      // status defaults to PENDING
      expect(m.status, 'PENDING');
    });
  });

  group('ProgressData.fromJson', () {
    test('parses progress data with nested milestones', () {
      final json = {
        'overallProgress': 42.5,
        'daysRemaining': 120,
        'totalDays': 365,
        'daysElapsed': 245,
        'progressStatus': 'ON_TRACK',
        'milestones': [
          {
            'name': 'Foundation',
            'progressPercentage': 100,
            'status': 'COMPLETED',
          },
          {
            'name': 'Superstructure',
            'progressPercentage': 40,
            'status': 'IN_PROGRESS',
          },
        ],
      };

      final data = ProgressData.fromJson(json);

      expect(data.overallProgress, 42.5);
      expect(data.daysRemaining, 120);
      expect(data.totalDays, 365);
      expect(data.daysElapsed, 245);
      expect(data.progressStatus, 'ON_TRACK');
      expect(data.milestones, hasLength(2));
      expect(data.milestones[0].name, 'Foundation');
      expect(data.milestones[0].progressPercentage, 100.0);
      expect(data.milestones[1].status, 'IN_PROGRESS');
    });

    test('applies defaults and empty milestones list', () {
      final data = ProgressData.fromJson({});

      expect(data.overallProgress, 0.0);
      expect(data.daysRemaining, 0);
      expect(data.totalDays, 0);
      expect(data.daysElapsed, 0);
      // progressStatus defaults to UNKNOWN
      expect(data.progressStatus, 'UNKNOWN');
      expect(data.milestones, isEmpty);
    });
  });

  group('DashboardDto.fromJson', () {
    test('parses a full dashboard payload', () {
      final json = {
        'user': {
          'id': 24,
          'email': 'demo@walldot.in',
          'firstName': 'Demo',
          'lastName': 'Customer',
          'role': 'CUSTOMER',
        },
        'projects': {
          'totalProjects': 2,
          'activeProjects': 1,
          'completedProjects': 1,
          'recentProjects': [
            {'id': 49, 'name': 'Villa A', 'progress': 30},
          ],
        },
        'recentActivities': [
          {
            'type': 'PAYMENT',
            'description': 'Payment received',
            'timestamp': '2026-05-10T09:30:00',
            'projectId': 49,
            'projectName': 'Villa A',
          },
        ],
        'quickStats': {
          'totalBills': 5,
          'pendingBills': 2,
          'paidBills': 3,
          'totalAmount': 1000000,
          'pendingAmount': 400000,
        },
      };

      final dto = DashboardDto.fromJson(json);

      expect(dto.user.id, 24);
      expect(dto.user.fullName, 'Demo Customer');
      expect(dto.projects.totalProjects, 2);
      expect(dto.projects.recentProjects, hasLength(1));
      expect(dto.projects.recentProjects[0].name, 'Villa A');
      expect(dto.recentActivities, hasLength(1));
      expect(dto.recentActivities[0].type, 'PAYMENT');
      expect(dto.quickStats.totalBills, 5);
      expect(dto.quickStats.totalAmount, 1000000.0);
    });

    test('applies defaults for empty payload', () {
      final dto = DashboardDto.fromJson({});

      expect(dto.user.id, 0);
      expect(dto.projects.totalProjects, 0);
      expect(dto.projects.recentProjects, isEmpty);
      expect(dto.recentActivities, isEmpty);
      expect(dto.quickStats.totalBills, 0);
    });
  });

  group('ApiResponse.fromJson', () {
    test('parses a success wrapper invoking fromJsonT on data', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'id': 49,
          'name': 'Villa A',
          'progress': 30,
        },
      };

      final res = ApiResponse<ProjectCard>.fromJson(
        json,
        (d) => ProjectCard.fromJson(d as Map<String, dynamic>),
      );

      expect(res.success, true);
      expect(res.message, 'OK');
      expect(res.data, isNotNull);
      expect(res.data!.id, 49);
      expect(res.data!.name, 'Villa A');
      // error is never set by fromJson
      expect(res.error, isNull);
    });

    test('leaves data null when payload data is null and defaults success', () {
      final res = ApiResponse<ProjectCard>.fromJson(
        {'data': null},
        (d) => ProjectCard.fromJson(d as Map<String, dynamic>),
      );

      // success defaults to true
      expect(res.success, true);
      expect(res.data, isNull);
      expect(res.message, isNull);
    });

    test('respects explicit success:false', () {
      final res = ApiResponse<ProjectCard>.fromJson(
        {'success': false, 'message': 'Failed'},
        (d) => ProjectCard.fromJson(d as Map<String, dynamic>),
      );

      expect(res.success, false);
      expect(res.message, 'Failed');
      expect(res.data, isNull);
    });
  });

  group('ProjectDocumentSummary.fromJson', () {
    test('parses a document with upload date', () {
      final doc = ProjectDocumentSummary.fromJson({
        'id': 11,
        'filename': 'agreement.pdf',
        'downloadUrl': 'https://cdn/agreement.pdf',
        'fileSize': 204800,
        'fileType': 'application/pdf',
        'categoryName': 'Legal',
        'uploadDate': '2026-04-23T10:00:00',
        'uploadedBy': 'admin',
      });

      expect(doc.id, 11);
      expect(doc.filename, 'agreement.pdf');
      expect(doc.downloadUrl, 'https://cdn/agreement.pdf');
      expect(doc.fileSize, 204800);
      expect(doc.fileType, 'application/pdf');
      expect(doc.categoryName, 'Legal');
      expect(doc.uploadDate, DateTime.parse('2026-04-23T10:00:00'));
      expect(doc.uploadedBy, 'admin');
    });

    test('applies defaults and null uploadDate when absent', () {
      final doc = ProjectDocumentSummary.fromJson({});

      expect(doc.id, 0);
      expect(doc.filename, '');
      expect(doc.downloadUrl, '');
      expect(doc.fileSize, isNull);
      expect(doc.fileType, isNull);
      expect(doc.categoryName, isNull);
      expect(doc.uploadDate, isNull);
      expect(doc.uploadedBy, isNull);
    });
  });

  group('ProjectPhaseModel.fromJson', () {
    test('parses a phase with all timeline dates', () {
      final phase = ProjectPhaseModel.fromJson({
        'id': 3,
        'phaseName': 'Superstructure',
        'status': 'IN_PROGRESS',
        'displayOrder': 2,
        'plannedStart': '2026-02-01T00:00:00',
        'plannedEnd': '2026-05-01T00:00:00',
        'actualStart': '2026-02-03T00:00:00',
        'actualEnd': null,
      });

      expect(phase.id, 3);
      expect(phase.phaseName, 'Superstructure');
      expect(phase.status, 'IN_PROGRESS');
      expect(phase.displayOrder, 2);
      expect(phase.plannedStart, DateTime.parse('2026-02-01T00:00:00'));
      expect(phase.plannedEnd, DateTime.parse('2026-05-01T00:00:00'));
      expect(phase.actualStart, DateTime.parse('2026-02-03T00:00:00'));
      expect(phase.actualEnd, isNull);
      expect(phase.isInProgress, true);
      expect(phase.isCompleted, false);
      expect(phase.isDelayed, false);
    });

    test('applies defaults and tolerates an unparseable date', () {
      final phase = ProjectPhaseModel.fromJson({
        'phaseName': 'Foundation',
        // DateTime.tryParse returns null for garbage instead of throwing
        'plannedStart': 'not-a-date',
      });

      expect(phase.id, 0);
      expect(phase.phaseName, 'Foundation');
      // status defaults to NOT_STARTED
      expect(phase.status, 'NOT_STARTED');
      expect(phase.displayOrder, isNull);
      expect(phase.plannedStart, isNull);
      expect(phase.plannedEnd, isNull);
      expect(phase.actualStart, isNull);
      expect(phase.actualEnd, isNull);
      expect(phase.isInProgress, false);
    });

    test('isCompleted / isDelayed status helpers', () {
      expect(
        ProjectPhaseModel.fromJson({'status': 'COMPLETED'}).isCompleted,
        true,
      );
      expect(
        ProjectPhaseModel.fromJson({'status': 'DELAYED'}).isDelayed,
        true,
      );
    });
  });

  group('ProjectDetails.fromJson', () {
    test('parses a full project details payload with nested data', () {
      final json = {
        'id': 49,
        'projectUuid': '6043e82e-aaaa-bbbb-cccc-dddddddddddd',
        'name': 'Demo Villa G+1',
        'code': 'PRJ-2026-0049',
        'location': 'Kochi',
        'startDate': '2026-01-01',
        'endDate': '2026-12-31',
        'status': 'CONSTRUCTION',
        'progress': 42.5,
        'projectPhase': 'SUPERSTRUCTURE',
        'projectType': 'NEW_BUILD',
        'designPackage': 'PREMIUM',
        'isDesignAgreementSigned': true,
        'state': 'Kerala',
        'createdBy': 'admin',
        'responsiblePerson': 'Site Engineer',
        'sqFeet': 1800.5,
        'leadId': 'LEAD-100',
        'documents': [
          {
            'id': 11,
            'filename': 'agreement.pdf',
            'downloadUrl': 'https://cdn/agreement.pdf',
          },
        ],
        'progressData': {
          'overallProgress': 42.5,
          'daysRemaining': 120,
          'totalDays': 365,
          'daysElapsed': 245,
          'progressStatus': 'ON_TRACK',
          'milestones': [],
        },
        'designProgress': 100,
        'contractValueDisplay': 'Rs 1.5 Cr',
        'estimatedCompletionDate': '2026-12-31',
      };

      final p = ProjectDetails.fromJson(json);

      expect(p.id, 49);
      expect(p.projectUuid, '6043e82e-aaaa-bbbb-cccc-dddddddddddd');
      expect(p.name, 'Demo Villa G+1');
      expect(p.code, 'PRJ-2026-0049');
      expect(p.location, 'Kochi');
      expect(p.startDate, '2026-01-01');
      expect(p.endDate, '2026-12-31');
      expect(p.status, 'CONSTRUCTION');
      expect(p.progress, 42.5);
      // phase reads from json['projectPhase']
      expect(p.phase, 'SUPERSTRUCTURE');
      expect(p.projectType, 'NEW_BUILD');
      expect(p.designPackage, 'PREMIUM');
      expect(p.isDesignAgreementSigned, true);
      expect(p.state, 'Kerala');
      expect(p.createdBy, 'admin');
      expect(p.responsiblePerson, 'Site Engineer');
      expect(p.sqFeet, 1800.5);
      expect(p.leadId, 'LEAD-100');
      expect(p.documents, hasLength(1));
      expect(p.documents[0].filename, 'agreement.pdf');
      expect(p.progressData, isNotNull);
      expect(p.progressData!.overallProgress, 42.5);
      expect(p.designProgress, 100.0);
      expect(p.contractValueDisplay, 'Rs 1.5 Cr');
      expect(p.estimatedCompletionDate, '2026-12-31');
    });

    test('applies defaults, empty documents, null progressData', () {
      final p = ProjectDetails.fromJson({'id': 5, 'name': 'Bare'});

      expect(p.id, 5);
      expect(p.name, 'Bare');
      expect(p.projectUuid, isNull);
      expect(p.code, isNull);
      expect(p.location, isNull);
      expect(p.status, isNull);
      expect(p.progress, 0.0);
      expect(p.phase, isNull);
      expect(p.isDesignAgreementSigned, false);
      expect(p.state, isNull);
      // sqFeet is nullable and stays null (not coerced to 0)
      expect(p.sqFeet, isNull);
      expect(p.leadId, isNull);
      expect(p.documents, isEmpty);
      expect(p.progressData, isNull);
      expect(p.designProgress, 0.0);
      expect(p.contractValueDisplay, isNull);
      expect(p.estimatedCompletionDate, isNull);
    });
  });
}
