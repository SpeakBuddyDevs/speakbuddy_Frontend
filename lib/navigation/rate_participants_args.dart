import '../models/joined_exchange.dart';

class RateParticipantInfo {
  final String userId;
  final String username;
  final String? avatarUrl;

  const RateParticipantInfo({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  factory RateParticipantInfo.fromParticipant(JoinedExchangeParticipant p) {
    return RateParticipantInfo(
      userId: p.userId.toString(),
      username: p.username,
      avatarUrl: null,
    );
  }
}

class RateParticipantsArgs {
  final String exchangeId;
  final String? exchangeTitle;
  final List<RateParticipantInfo> participants;

  const RateParticipantsArgs({
    required this.exchangeId,
    this.exchangeTitle,
    required this.participants,
  });
}
