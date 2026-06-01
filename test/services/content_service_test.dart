import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/config/api_config.dart';
import 'package:wd_cust_mobile_app/models/content_models.dart';
import 'package:wd_cust_mobile_app/services/content_service.dart';

import '../test_helpers/mock_dio_adapter.dart';

void main() {
  late MockDioAdapter adapter;

  setUp(() {
    adapter = MockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://test.example'))
      ..httpClientAdapter = adapter;
    ContentService.testDio = dio;
  });

  tearDown(() {
    ContentService.testDio = null;
  });

  group('ContentService.getLiveActivities', () {
    test('parses a JSON list into LiveActivity models', () async {
      adapter.onGet(ApiConfig.liveActivitiesEndpoint, (_) async => jsonResponse([
            {
              'customerName': 'Krishnan',
              'location': 'Kochi',
              'action': 'started a project',
              'timestamp': '2026-05-10T10:00:00Z',
            },
            {
              'customerName': 'Anand',
              'location': 'Trivandrum',
              'action': 'requested a quote',
            },
          ]));

      final result = await ContentService.getLiveActivities();

      expect(result, hasLength(2));
      expect(result[0].customerName, 'Krishnan');
      expect(result[0].location, 'Kochi');
      expect(result[0].action, 'started a project');
      expect(result[0].timestamp, '2026-05-10T10:00:00Z');
      expect(result[1].customerName, 'Anand');
      expect(result[1].timestamp, isNull);
    });

    test('returns empty list when body is not a List', () async {
      adapter.onGet(ApiConfig.liveActivitiesEndpoint,
          (_) async => jsonResponse({'error': 'unexpected'}));

      final result = await ContentService.getLiveActivities();

      expect(result, isEmpty);
    });

    test('returns empty list on non-200 (DioException)', () async {
      adapter.onGet(ApiConfig.liveActivitiesEndpoint,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final result = await ContentService.getLiveActivities();

      expect(result, isEmpty);
    });

    test('returns empty list when adapter throws (network error)', () async {
      // No handler registered -> MockDioAdapter throws -> service catches.
      final result = await ContentService.getLiveActivities();

      expect(result, isEmpty);
    });
  });

  group('ContentService.getBlogs', () {
    test('parses paged content into BlogPost models', () async {
      adapter.onGet(ApiConfig.blogsEndpoint, (_) async => jsonResponse({
            'content': [
              {
                'id': 1,
                'title': 'How to plan a G+1',
                'slug': 'plan-g-plus-1',
                'excerpt': 'A short guide',
                'author': 'Wall.Dot',
                'publishedAt': '2026-04-01',
              },
            ],
            'totalElements': 23,
            'totalPages': 3,
          }));

      final result = await ContentService.getBlogs();

      final content = result['content'] as List<BlogPost>;
      expect(content, hasLength(1));
      expect(content.first.title, 'How to plan a G+1');
      expect(content.first.slug, 'plan-g-plus-1');
      expect(result['totalElements'], 23);
      expect(result['totalPages'], 3);
    });

    test('passes page, size and search query params', () async {
      String? capturedQuery;
      adapter.onGet(ApiConfig.blogsEndpoint, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse(
            {'content': [], 'totalElements': 0, 'totalPages': 0});
      });

      await ContentService.getBlogs(page: 2, size: 5, search: 'cement');

      expect(capturedQuery, contains('page=2'));
      expect(capturedQuery, contains('size=5'));
      expect(capturedQuery, contains('search=cement'));
    });

    test('omits search param when empty', () async {
      String? capturedQuery;
      adapter.onGet(ApiConfig.blogsEndpoint, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse(
            {'content': [], 'totalElements': 0, 'totalPages': 0});
      });

      await ContentService.getBlogs(search: '');

      expect(capturedQuery, isNot(contains('search')));
    });

    test('returns empty/zero map when body is not paged', () async {
      adapter.onGet(
          ApiConfig.blogsEndpoint, (_) async => jsonResponse([1, 2, 3]));

      final result = await ContentService.getBlogs();

      expect(result['content'], isEmpty);
      expect(result['totalElements'], 0);
      expect(result['totalPages'], 0);
    });

    test('returns empty/zero map on DioException', () async {
      adapter.onGet(ApiConfig.blogsEndpoint,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final result = await ContentService.getBlogs();

      expect(result['content'], isEmpty);
      expect(result['totalElements'], 0);
      expect(result['totalPages'], 0);
    });
  });

  group('ContentService.getBlogBySlug', () {
    test('parses a single BlogPost on map body', () async {
      adapter.onGet('${ApiConfig.blogsEndpoint}/my-slug',
          (_) async => jsonResponse({
                'id': 7,
                'title': 'Slugged post',
                'slug': 'my-slug',
                'excerpt': 'ex',
                'author': 'Author',
              }));

      final result = await ContentService.getBlogBySlug('my-slug');

      expect(result, isNotNull);
      expect(result!.id, '7');
      expect(result.title, 'Slugged post');
      expect(result.slug, 'my-slug');
    });

    test('returns null when body is not a map', () async {
      adapter.onGet('${ApiConfig.blogsEndpoint}/my-slug',
          (_) async => jsonResponse([]));

      final result = await ContentService.getBlogBySlug('my-slug');

      expect(result, isNull);
    });

    test('returns null on DioException', () async {
      adapter.onGet('${ApiConfig.blogsEndpoint}/missing',
          (_) async => jsonResponse({'error': 'nope'}, statusCode: 404));

      final result = await ContentService.getBlogBySlug('missing');

      expect(result, isNull);
    });
  });

  group('ContentService.getPortfolio', () {
    test('parses paged content into PortfolioItem models', () async {
      adapter.onGet(ApiConfig.portfolioEndpoint, (_) async => jsonResponse({
            'content': [
              {
                'id': 11,
                'title': 'Villa at Kochi',
                'slug': 'villa-kochi',
                'projectType': 'NEW_BUILD',
                'areaSqft': 2400,
                'imageUrls': ['a.jpg', 'b.jpg'],
              },
            ],
            'totalElements': 4,
            'totalPages': 1,
          }));

      final result = await ContentService.getPortfolio();

      final content = result['content'] as List<PortfolioItem>;
      expect(content, hasLength(1));
      expect(content.first.title, 'Villa at Kochi');
      expect(content.first.areaSqft, 2400);
      expect(content.first.imageUrls, ['a.jpg', 'b.jpg']);
      expect(result['totalElements'], 4);
      expect(result['totalPages'], 1);
    });

    test('passes projectType query param when provided', () async {
      String? capturedQuery;
      adapter.onGet(ApiConfig.portfolioEndpoint, (options) async {
        capturedQuery = options.uri.query;
        return jsonResponse(
            {'content': [], 'totalElements': 0, 'totalPages': 0});
      });

      await ContentService.getPortfolio(projectType: 'NEW_BUILD');

      expect(capturedQuery, contains('projectType=NEW_BUILD'));
    });

    test('returns empty/zero map on DioException', () async {
      adapter.onGet(ApiConfig.portfolioEndpoint,
          (_) async => jsonResponse({'error': 'boom'}, statusCode: 500));

      final result = await ContentService.getPortfolio();

      expect(result['content'], isEmpty);
      expect(result['totalElements'], 0);
      expect(result['totalPages'], 0);
    });
  });

  group('ContentService.getPortfolioBySlug', () {
    test('parses a single PortfolioItem on map body', () async {
      adapter.onGet('${ApiConfig.portfolioEndpoint}/villa-kochi',
          (_) async => jsonResponse({
                'id': 11,
                'title': 'Villa at Kochi',
                'slug': 'villa-kochi',
                'imageUrls': ['cover.jpg'],
              }));

      final result = await ContentService.getPortfolioBySlug('villa-kochi');

      expect(result, isNotNull);
      expect(result!.slug, 'villa-kochi');
      expect(result.imageUrls, ['cover.jpg']);
    });

    test('returns null when body is not a map', () async {
      adapter.onGet('${ApiConfig.portfolioEndpoint}/villa-kochi',
          (_) async => jsonResponse([]));

      final result = await ContentService.getPortfolioBySlug('villa-kochi');

      expect(result, isNull);
    });

    test('returns null on DioException', () async {
      adapter.onGet('${ApiConfig.portfolioEndpoint}/missing',
          (_) async => jsonResponse({'error': 'nope'}, statusCode: 404));

      final result = await ContentService.getPortfolioBySlug('missing');

      expect(result, isNull);
    });
  });
}
