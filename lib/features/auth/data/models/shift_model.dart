class ShiftModel {
  final int id;
  final String name;
  final String startsAt;
  final String endsAt;

  const ShiftModel({
    required this.id,
    required this.name,
    required this.startsAt,
    required this.endsAt,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '',
      startsAt: json['starts_at'] as String? ?? '',
      endsAt: json['ends_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'starts_at': startsAt,
    'ends_at': endsAt,
  };

  String get displayLabel {
    if (startsAt.isNotEmpty && endsAt.isNotEmpty) {
      return '$name ($startsAt - $endsAt)';
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
