enum ChatType { group, peer }

class ChatThread {
  const ChatThread({
    required this.id,
    required this.name,
    required this.type,
    required this.lastMessage,
    required this.timestamp,
    this.avatarEmoji = '💬',
    this.unreadCount = 0,
    this.isTyping = false,
    this.memberCount = 0,
    this.onlineCount = 0,
    this.isOnline = false,
  });

  final String id;
  final String name;
  final ChatType type;
  final String lastMessage;
  final String timestamp;
  final String avatarEmoji;
  final int unreadCount;
  final bool isTyping;
  final int memberCount;
  final int onlineCount;
  final bool isOnline;

  ChatThread copyWith({
    String? lastMessage,
    String? timestamp,
    int? unreadCount,
    bool? isTyping,
  }) {
    return ChatThread(
      id: id,
      name: name,
      type: type,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      avatarEmoji: avatarEmoji,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
      memberCount: memberCount,
      onlineCount: onlineCount,
      isOnline: isOnline,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
        'avatarEmoji': avatarEmoji,
        'unreadCount': unreadCount,
        'isTyping': isTyping ? 1 : 0,
        'memberCount': memberCount,
        'onlineCount': onlineCount,
        'isOnline': isOnline ? 1 : 0,
      };

  factory ChatThread.fromMap(Map<String, dynamic> map) {
    return ChatThread(
      id: map['id'] as String,
      name: map['name'] as String,
      type: ChatType.values.byName(map['type'] as String),
      lastMessage: map['lastMessage'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? '',
      avatarEmoji: map['avatarEmoji'] as String? ?? '💬',
      unreadCount: map['unreadCount'] as int? ?? 0,
      isTyping: (map['isTyping'] as int? ?? 0) == 1,
      memberCount: map['memberCount'] as int? ?? 0,
      onlineCount: map['onlineCount'] as int? ?? 0,
      isOnline: (map['isOnline'] as int? ?? 0) == 1,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isMine = false,
    this.isRead = false,
    this.attachmentName,
    this.attachmentSize,
  });

  final String id;
  final String threadId;
  final String senderName;
  final String content;
  final String timestamp;
  final bool isMine;
  final bool isRead;
  final String? attachmentName;
  final String? attachmentSize;

  Map<String, dynamic> toMap() => {
        'id': id,
        'threadId': threadId,
        'senderName': senderName,
        'content': content,
        'timestamp': timestamp,
        'isMine': isMine ? 1 : 0,
        'isRead': isRead ? 1 : 0,
        'attachmentName': attachmentName,
        'attachmentSize': attachmentSize,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      threadId: map['threadId'] as String,
      senderName: map['senderName'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as String,
      isMine: (map['isMine'] as int? ?? 0) == 1,
      isRead: (map['isRead'] as int? ?? 0) == 1,
      attachmentName: map['attachmentName'] as String?,
      attachmentSize: map['attachmentSize'] as String?,
    );
  }
}
