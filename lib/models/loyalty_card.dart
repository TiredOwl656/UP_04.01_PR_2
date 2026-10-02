class LoyaltyCard {
  final String number;
  final int bonusPoints;
  final DateTime issuedAt;

  const LoyaltyCard({
    required this.number,
    required this.bonusPoints,
    required this.issuedAt,
  });

  LoyaltyCard copyWith({
    String? number,
    int? bonusPoints,
    DateTime? issuedAt,
  }) =>
      LoyaltyCard(
        number: number ?? this.number,
        bonusPoints: bonusPoints ?? this.bonusPoints,
        issuedAt: issuedAt ?? this.issuedAt,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'bonusPoints': bonusPoints,
        'issuedAt': issuedAt.toIso8601String(),
      };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        number: json['number'] as String? ?? '',
        bonusPoints: json['bonusPoints'] as int? ?? 0,
        issuedAt: DateTime.tryParse(json['issuedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}