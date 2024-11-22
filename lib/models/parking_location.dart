class ParkingLocation {
  final String id;
  final String floor;
  final String section;
  final String? memo;
  final DateTime createdAt;

  ParkingLocation({
    required this.id,
    required this.floor,
    required this.section,
    this.memo,
    required this.createdAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor': floor,
      'section': section,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory ParkingLocation.fromJson(Map<String, dynamic> json) {
    return ParkingLocation(
      id: json['id'],
      floor: json['floor'],
      section: json['section'],
      memo: json['memo'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
