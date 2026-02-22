import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import 'reviews_repository.dart';

class ApiReviewsRepository implements ReviewsRepository {
  final _authService = AuthService();

  @override
  Future<bool> submitReview(String userId, ReviewRequest review) async {
    try {
      final headers = await _authService.headersWithAuth();
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) return false;

      final url = Uri.parse(ApiEndpoints.userReviews(userId));
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(review.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      print('🔴 [Reviews] submitReview ${response.statusCode}: ${response.body}');
      return false;
    } catch (e, st) {
      print('🔴 [Reviews] submitReview error: $e');
      print(st);
      return false;
    }
  }
}
