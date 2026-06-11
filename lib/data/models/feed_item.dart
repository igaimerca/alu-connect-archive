enum FeedItemType { event, opportunity, club, announcement }

enum RsvpStatus { none, interested, going }

class FeedItem {
  const FeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.campus,
    required this.category,
    required this.host,
    this.imageUrl = '',
    this.date = '',
    this.time = '',
    this.endTime = '',
    this.location = '',
    this.deadline = '',
    this.attendeeCount = 0,
    this.cohortMatches = 0,
    this.isFeatured = false,
    this.tags = const [],
    this.memberCount = 0,
    this.createdAt,
  });

  final String id;
  final FeedItemType type;
  final String title;
  final String description;
  final String campus;
  final String category;
  final String host;
  final String imageUrl;
  final String date;
  final String time;
  final String endTime;
  final String location;
  final String deadline;
  final int attendeeCount;
  final int cohortMatches;
  final bool isFeatured;
  final List<String> tags;
  final int memberCount;
  final DateTime? createdAt;

  bool get isEvent =>
      type == FeedItemType.event || type == FeedItemType.announcement;

  FeedItem copyWith({
    FeedItemType? type,
    String? title,
    String? description,
    String? campus,
    String? category,
    String? imageUrl,
    String? date,
    String? time,
    String? endTime,
    String? location,
    String? deadline,
    int? attendeeCount,
    bool? isFeatured,
    List<String>? tags,
  }) {
    return FeedItem(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      campus: campus ?? this.campus,
      category: category ?? this.category,
      host: host,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      deadline: deadline ?? this.deadline,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      cohortMatches: cohortMatches,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      memberCount: memberCount,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'campus': campus,
        'category': category,
        'host': host,
        'imageUrl': imageUrl,
        'date': date,
        'time': time,
        'endTime': endTime,
        'location': location,
        'deadline': deadline,
        'attendeeCount': attendeeCount,
        'cohortMatches': cohortMatches,
        'isFeatured': isFeatured ? 1 : 0,
        'tags': tags.join(','),
        'memberCount': memberCount,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      id: map['id'] as String,
      type: FeedItemType.values.byName(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      campus: map['campus'] as String,
      category: map['category'] as String,
      host: map['host'] as String,
      imageUrl: map['imageUrl'] as String? ?? '',
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      endTime: map['endTime'] as String? ?? '',
      location: map['location'] as String? ?? '',
      deadline: map['deadline'] as String? ?? '',
      attendeeCount: map['attendeeCount'] as int? ?? 0,
      cohortMatches: map['cohortMatches'] as int? ?? 0,
      isFeatured: (map['isFeatured'] as int? ?? 0) == 1,
      tags: (map['tags'] as String? ?? '').split(',').where((t) => t.isNotEmpty).toList(),
      memberCount: map['memberCount'] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}
