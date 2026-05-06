import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/project_models.dart';
import 'package:wd_cust_mobile_app/models/team_contact.dart';
import 'package:wd_cust_mobile_app/models/timeline_item.dart';
import 'package:wd_cust_mobile_app/providers/project_provider.dart';
import 'package:wd_cust_mobile_app/repositories/project_repository.dart';
import 'package:wd_cust_mobile_app/services/expected_handover_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

/// Skeletal repository — only methods called by the tests below need to be
/// usable. Anything else will throw UnimplementedError if accidentally invoked.
class _FakeProjectRepository implements ProjectRepository {
  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());

  // Methods from the abstract base — only the ones the provider's
  // loadExpectedHandover path touches need real bodies; the others are
  // covered by noSuchMethod.
  @override
  Future<List<Project>> getProjects() async => <Project>[];
  @override
  Future<Project?> getProjectById(String projectId) async => null;
  @override
  Future<List<Project>> searchProjects(String query) async => <Project>[];
  @override
  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async =>
      <Project>[];
  @override
  Future<List<Project>> sortProjectsByProgress() async => <Project>[];
  @override
  Future<List<Project>> sortProjectsByLastUpdated() async => <Project>[];
  @override
  Future<List<Document>> getDocuments(String projectId) async => <Document>[];
  @override
  Future<Document?> getDocumentById(String documentId) async => null;
  @override
  Future<String> downloadDocument(String documentId) async => '';
  @override
  Future<List<QCItem>> getQCItems(String projectId) async => <QCItem>[];
  @override
  Future<QCItem?> getQCItemById(String qcId) async => null;
  @override
  Future<bool> updateQCStatus(
          String qcId, QCStatus status, String comments) async =>
      true;
  @override
  Future<List<Query>> getQueries(String projectId) async => <Query>[];
  @override
  Future<Query?> getQueryById(String queryId) async => null;
  @override
  Future<String> createQuery(String projectId, Query query) async => '';
  @override
  Future<bool> addQueryMessage(String queryId, QueryMessage message) async =>
      true;
  @override
  Future<bool> updateQueryStatus(String queryId, QueryStatus status) async =>
      true;
  @override
  Future<List<ProjectActivity>> getProjectActivities(String projectId) async =>
      <ProjectActivity>[];
  @override
  Future<List<ProjectActivity>> getRecentActivities(
          String projectId, int limit) async =>
      <ProjectActivity>[];
  @override
  Future<List<Payment>> getPayments(String projectId) async => <Payment>[];
  @override
  Future<Payment?> getPaymentById(String paymentId) async => null;
  @override
  Future<String> downloadInvoice(String paymentId) async => '';
  @override
  Future<List<GalleryPhoto>> getGalleryPhotos(String projectId) async =>
      <GalleryPhoto>[];
  @override
  Future<GalleryPhoto?> getGalleryPhotoById(String photoId) async => null;
  @override
  Future<List<SurveillanceCamera>> getSurveillanceCameras(
          String projectId) async =>
      <SurveillanceCamera>[];
  @override
  Future<String> getCameraStreamUrl(String cameraId) async => '';
  @override
  Future<List<ProgressDataPoint>> getProgressData(String projectId) async =>
      <ProgressDataPoint>[];
  @override
  Future<List<TeamContact>> fetchTeam(String projectUuid) async =>
      <TeamContact>[];
  @override
  Future<TimelinePage> fetchTimeline(String projectUuid, String bucket,
          {int page = 0, int size = 20}) async =>
      const TimelinePage(
        items: [],
        totalElements: 0,
        totalPages: 0,
        page: 0,
        size: 0,
        projectProgressPercent: 0,
      );
  @override
  Future<TimelineSummary> fetchTimelineSummary(String projectUuid) async =>
      const TimelineSummary(
        weekCount: 0,
        upcomingCount: 0,
        completedCount: 0,
        projectProgressPercent: 0,
      );
}

void main() {
  late ProjectProvider provider;
  late MockDioAdapter adapter;

  setUp(() {
    provider = ProjectProvider(_FakeProjectRepository());
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
    dio.httpClientAdapter = adapter;
    ExpectedHandoverService.testDio = dio;
  });

  tearDown(() {
    ExpectedHandoverService.testDio = null;
  });

  test('loadExpectedHandover stores result and notifies listeners', () async {
    adapter.onGet(
      '/api/customer/projects/abc/expected-handover',
      (_) async => jsonResponse({
        'projectFinishDate': '2026-08-12',
        'baselineFinishDate': '2026-08-05',
        'weeksRemaining': 14,
        'hasMaterialDelay': true,
      }),
    );
    int notifyCount = 0;
    provider.addListener(() => notifyCount++);

    await provider.loadExpectedHandover('abc');

    expect(provider.expectedHandover, isNotNull);
    expect(provider.expectedHandover!.projectFinishDate, DateTime(2026, 8, 12));
    expect(notifyCount, greaterThanOrEqualTo(1));
  });

  test('loadExpectedHandover stores null on 404', () async {
    adapter.onGet(
      '/api/customer/projects/abc/expected-handover',
      (_) async => jsonResponse({'error': 'Not found'}, statusCode: 404),
    );

    await provider.loadExpectedHandover('abc');

    expect(provider.expectedHandover, isNull);
  });
}
