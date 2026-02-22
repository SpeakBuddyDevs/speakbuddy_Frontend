class ReviewRequest {
  final int score;
  final String? comment;

  const ReviewRequest({
    required this.score,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        if (comment != null && comment!.isNotEmpty) 'comment': comment,
      };
}
