class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.campus,
    required this.cohort,
    this.bio = '',
    this.avatarUrl = '',
    this.eventsCount = 0,
    this.communitiesCount = 0,
    this.connectionsCount = 0,
    this.canPost = false,
  });

  final String id;
  final String name;
  final String email;
  final String campus;
  final String cohort;
  final String bio;
  final String avatarUrl;
  final int eventsCount;
  final int communitiesCount;
  final int connectionsCount;
  final bool canPost;

  UserProfile copyWith({
    String? name,
    String? email,
    String? campus,
    String? cohort,
    String? bio,
    String? avatarUrl,
    int? eventsCount,
    int? communitiesCount,
    int? connectionsCount,
    bool? canPost,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      campus: campus ?? this.campus,
      cohort: cohort ?? this.cohort,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      eventsCount: eventsCount ?? this.eventsCount,
      communitiesCount: communitiesCount ?? this.communitiesCount,
      connectionsCount: connectionsCount ?? this.connectionsCount,
      canPost: canPost ?? this.canPost,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'campus': campus,
        'cohort': cohort,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'eventsCount': eventsCount,
        'communitiesCount': communitiesCount,
        'connectionsCount': connectionsCount,
        'canPost': canPost ? 1 : 0,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      campus: json['campus'] as String,
      cohort: json['cohort'] as String,
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      eventsCount: json['eventsCount'] as int? ?? 0,
      communitiesCount: json['communitiesCount'] as int? ?? 0,
      connectionsCount: json['connectionsCount'] as int? ?? 0,
      canPost: (json['canPost'] as int? ?? 0) == 1,
    );
  }
}
