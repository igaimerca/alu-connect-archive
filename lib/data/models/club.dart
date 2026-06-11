class Club {
  const Club({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.memberCount,
    this.campus = 'All Campuses',
    this.isJoined = false,
  });

  final String id;
  final String name;
  final String description;
  final String iconName;
  final int memberCount;
  final String campus;
  final bool isJoined;

  Club copyWith({bool? isJoined, int? memberCount}) {
    return Club(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      memberCount: memberCount ?? this.memberCount,
      campus: campus,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'iconName': iconName,
        'memberCount': memberCount,
        'campus': campus,
      };

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'groups',
      memberCount: map['memberCount'] as int? ?? 0,
      campus: map['campus'] as String? ?? 'All Campuses',
    );
  }
}
