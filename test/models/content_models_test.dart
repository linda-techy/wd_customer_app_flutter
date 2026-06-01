import 'package:flutter_test/flutter_test.dart';
import 'package:wd_cust_mobile_app/models/content_models.dart';

void main() {
  group('LiveActivity.fromJson', () {
    test('parses a real-shaped activity payload', () {
      final json = {
        'customerName': 'Ramesh',
        'location': 'Thrissur',
        'action': 'started construction',
        'timestamp': '2026-05-30T14:00:00',
      };

      final a = LiveActivity.fromJson(json);

      expect(a.customerName, 'Ramesh');
      expect(a.location, 'Thrissur');
      expect(a.action, 'started construction');
      expect(a.timestamp, '2026-05-30T14:00:00');
    });

    test('applies defaults and null timestamp on empty json', () {
      final a = LiveActivity.fromJson({});

      expect(a.customerName, '');
      expect(a.location, '');
      expect(a.action, '');
      expect(a.timestamp, isNull);
    });
  });

  group('BlogPost.fromJson', () {
    test('parses a full blog payload', () {
      final json = {
        'id': 'blog-1',
        'title': 'How we build',
        'slug': 'how-we-build',
        'excerpt': 'A short intro',
        'content': 'Full body text',
        'imageUrl': 'https://cdn/img.jpg',
        'author': 'WallDot Team',
        'publishedAt': '2026-05-01',
      };

      final b = BlogPost.fromJson(json);

      expect(b.id, 'blog-1');
      expect(b.title, 'How we build');
      expect(b.slug, 'how-we-build');
      expect(b.excerpt, 'A short intro');
      expect(b.content, 'Full body text');
      expect(b.imageUrl, 'https://cdn/img.jpg');
      expect(b.author, 'WallDot Team');
      expect(b.publishedAt, '2026-05-01');
    });

    test('coerces numeric id to string and nulls optionals', () {
      final b = BlogPost.fromJson({'id': 99});

      expect(b.id, '99');
      expect(b.title, '');
      expect(b.slug, '');
      expect(b.excerpt, '');
      expect(b.content, isNull);
      expect(b.imageUrl, isNull);
      expect(b.author, '');
      expect(b.publishedAt, isNull);
    });
  });

  group('PortfolioItem.fromJson', () {
    test('parses a full portfolio payload with image list', () {
      final json = {
        'id': 'p-1',
        'title': 'Modern Villa',
        'slug': 'modern-villa',
        'description': 'A 4BHK villa',
        'location': 'Kochi',
        'projectType': 'NEW_BUILD',
        'areaSqft': 2400,
        'completionDate': '2026-01-15',
        'coverImageUrl': 'https://cdn/cover.jpg',
        'imageUrls': ['https://cdn/1.jpg', 'https://cdn/2.jpg'],
      };

      final p = PortfolioItem.fromJson(json);

      expect(p.id, 'p-1');
      expect(p.title, 'Modern Villa');
      expect(p.slug, 'modern-villa');
      expect(p.description, 'A 4BHK villa');
      expect(p.location, 'Kochi');
      expect(p.projectType, 'NEW_BUILD');
      expect(p.areaSqft, 2400);
      expect(p.completionDate, '2026-01-15');
      expect(p.coverImageUrl, 'https://cdn/cover.jpg');
      expect(p.imageUrls, ['https://cdn/1.jpg', 'https://cdn/2.jpg']);
    });

    test('defaults imageUrls to empty list and areaSqft null when missing', () {
      final p = PortfolioItem.fromJson({'id': 'p-2'});

      expect(p.id, 'p-2');
      expect(p.title, '');
      expect(p.slug, '');
      expect(p.description, isNull);
      expect(p.areaSqft, isNull);
      expect(p.imageUrls, isEmpty);
    });

    test('non-int areaSqft collapses to null', () {
      final p = PortfolioItem.fromJson({'id': 'p-3', 'areaSqft': '2400'});
      expect(p.areaSqft, isNull);
    });

    test('non-list imageUrls collapses to empty list', () {
      final p = PortfolioItem.fromJson({'id': 'p-4', 'imageUrls': 'oops'});
      expect(p.imageUrls, isEmpty);
    });
  });
}
