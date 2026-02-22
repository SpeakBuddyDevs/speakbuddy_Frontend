import '../models/review.dart';

abstract class ReviewsRepository {
  Future<bool> submitReview(String userId, ReviewRequest review);
}
