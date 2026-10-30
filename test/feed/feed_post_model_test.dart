import 'package:flutter_test/flutter_test.dart';
import 'package:doc_connect_app/features/feed/data/models/feed_post_model.dart';
import 'package:doc_connect_app/features/feed/data/models/feed_response_model.dart';

void main() {
  group('FeedPostModel JSON parsing', () {
    test('parses full json structure safely', () {
      final json = {
        'id': 'post-1',
        'author': 'Dr. Sharma',
        'author_id': 'doc-101',
        'headline': 'Cardiologist',
        'initials': 'DS',
        'color': '#378FE9',
        'photo': '/media/doctors/ds.jpg',
        'post_type': 'clinical_case',
        'post_type_display': 'Clinical Case',
        'content': 'Interesting ECG finding today.',
        'image': '/media/posts/ecg.jpg',
        'like_count': 15,
        'comment_count': 3,
        'liked': true,
        'is_mine': false,
        'pii_flagged': true,
        'created_at': '2026-03-30T10:00:00Z',
      };

      final model = FeedPostModel.fromJson(json);

      expect(model.id, 'post-1');
      expect(model.author, 'Dr. Sharma');
      expect(model.authorId, 'doc-101');
      expect(model.likeCount, 15);
      expect(model.commentCount, 3);
      expect(model.liked, isTrue);
      expect(model.isMine, isFalse);
      expect(model.piiFlagged, isTrue);

      final entity = model.toEntity();
      expect(entity.piiFlagged, isTrue);
      expect(entity.id, 'post-1');
    });

    test('handles null and missing optional fields safely', () {
      final json = <String, dynamic>{'id': 'post-2'};

      final model = FeedPostModel.fromJson(json);

      expect(model.id, 'post-2');
      expect(model.author, '');
      expect(model.photo, isNull);
      expect(model.image, isNull);
      expect(model.likeCount, 0);
      expect(model.liked, isFalse);
      expect(model.isMine, isFalse);
      expect(model.piiFlagged, isFalse);
    });

    test('FeedResponseModel parses paginated feed payload', () {
      final json = {
        'posts': [
          {
            'id': 'post-10',
            'author': 'Dr. Patel',
            'author_id': 'doc-102',
            'headline': 'Neurologist',
            'initials': 'DP',
            'color': '#10B981',
            'post_type': 'update',
            'post_type_display': 'Update',
            'content': 'Hello network',
            'like_count': 5,
            'comment_count': 1,
            'liked': false,
            'is_mine': true,
            'pii_flagged': false,
            'created_at': '2026-03-30T11:00:00Z',
          },
        ],
        'page': 1,
        'page_size': 10,
        'has_more': true,
      };

      final response = FeedResponseModel.fromJson(json);

      expect(response.page, 1);
      expect(response.pageSize, 10);
      expect(response.hasMore, isTrue);
      expect(response.posts.length, 1);
      expect(response.posts.first.isMine, isTrue);
    });
  });
}
