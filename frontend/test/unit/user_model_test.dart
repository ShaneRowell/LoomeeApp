import 'package:flutter_test/flutter_test.dart';
import 'package:loomee/models/user.dart';

void main() {
  group('User.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        '_id': 'abc123',
        'email': 'test@example.com',
        'name': 'Test User',
        'avatarImage': 'https://example.com/avatar.png',
        'createdAt': '2025-01-15T10:00:00.000Z',
      };
      final user = User.fromJson(json);
      expect(user.id, equals('abc123'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.avatarImage, equals('https://example.com/avatar.png'));
      expect(user.createdAt, isNotNull);
    });

    test('accepts "id" key as fallback when "_id" is absent', () {
      final json = {'id': 'xyz789', 'email': 'a@b.com', 'name': 'Name'};
      final user = User.fromJson(json);
      expect(user.id, equals('xyz789'));
    });

    test('returns empty string for missing id', () {
      final json = {'email': 'a@b.com', 'name': 'Name'};
      final user = User.fromJson(json);
      expect(user.id, equals(''));
    });

    test('returns null avatarImage when field is absent', () {
      final json = {'_id': '1', 'email': 'a@b.com', 'name': 'Name'};
      final user = User.fromJson(json);
      expect(user.avatarImage, isNull);
    });

    test('returns null createdAt for absent or unparseable date', () {
      final json = {'_id': '1', 'email': 'a@b.com', 'name': 'Name', 'createdAt': 'not-a-date'};
      final user = User.fromJson(json);
      expect(user.createdAt, isNull);
    });

    test('parses bodyMeasurements when present', () {
      final json = {
        '_id': '1',
        'email': 'a@b.com',
        'name': 'Name',
        'bodyMeasurements': {
          'chest': 92.0,
          'waist': 76.0,
          'hips': 98.0,
          'height': 170.0,
          'weight': 65.0,
        },
      };
      final user = User.fromJson(json);
      expect(user.bodyMeasurements, isNotNull);
      expect(user.bodyMeasurements!.chest, equals(92.0));
      expect(user.bodyMeasurements!.waist, equals(76.0));
    });

    test('bodyMeasurements is null when field is absent', () {
      final json = {'_id': '1', 'email': 'a@b.com', 'name': 'Name'};
      final user = User.fromJson(json);
      expect(user.bodyMeasurements, isNull);
    });
  });

  group('BodyMeasurements.fromJson', () {
    test('parses all numeric fields correctly', () {
      final json = {
        'chest': 90,
        'waist': 74,
        'hips': 96,
        'height': 168,
        'weight': 60,
      };
      final bm = BodyMeasurements.fromJson(json);
      expect(bm.chest, equals(90.0));
      expect(bm.waist, equals(74.0));
      expect(bm.hips, equals(96.0));
      expect(bm.height, equals(168.0));
      expect(bm.weight, equals(60.0));
    });

    test('returns null for missing fields', () {
      final bm = BodyMeasurements.fromJson({});
      expect(bm.chest, isNull);
      expect(bm.waist, isNull);
    });
  });
}
