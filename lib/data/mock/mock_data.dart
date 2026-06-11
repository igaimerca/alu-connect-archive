import '../models/chat_models.dart';
import '../models/club.dart';
import '../models/feed_item.dart';

class MockData {
  MockData._();

  static final defaultUser = UserProfilePlaceholder(
    name: 'Patrick Mugisha',
    email: 'patrick.mugisha@alueducation.com',
    campus: 'Kigali',
    cohort: '2026',
  );

  static final feedItems = [
    FeedItem(
      id: 'evt-1',
      type: FeedItemType.event,
      title: 'AI & Data Science Workshop',
      description:
          'Explore practical AI and data science tools tailored for African contexts. '
          'Hands-on sessions with ALU Tech Hub mentors covering GPT APIs, campus automation, '
          'and ethical AI for leadership.',
      campus: 'Kigali',
      category: 'Workshop',
      host: 'ALU Tech Hub',
      date: 'Jul 18, 2026',
      time: '02:00 PM',
      endTime: '05:00 PM',
      location: 'Innovation Hub, Level 2',
      attendeeCount: 29,
      cohortMatches: 5,
      isFeatured: true,
      tags: ['Tech', 'Workshop'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FeedItem(
      id: 'evt-2',
      type: FeedItemType.event,
      title: 'ALU Innovate Summit 2026',
      description:
          'Pan-African student innovation showcase connecting founders, investors, and ALU alumni.',
      campus: 'Mauritius',
      category: 'Social',
      host: 'ALU Entrepreneurship',
      date: 'Sep 24, 2026',
      time: '09:00 AM',
      endTime: '06:00 PM',
      location: 'Main Auditorium',
      attendeeCount: 240,
      cohortMatches: 12,
      isFeatured: true,
      tags: ['Leadership', 'Social'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FeedItem(
      id: 'evt-3',
      type: FeedItemType.event,
      title: 'Intercampus Tech Summit',
      description: 'Cross-campus hackathon prep and networking for distributed ALU teams.',
      campus: 'Virtual Hub',
      category: 'Hackathon',
      host: 'Kigali Tech Hub',
      date: 'Jul 24, 2026',
      time: '10:00 AM',
      location: 'Virtual Hub',
      attendeeCount: 57,
      cohortMatches: 8,
      tags: ['Hackathon'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FeedItem(
      id: 'opp-1',
      type: FeedItemType.opportunity,
      title: 'Junior UX Researcher — Rwanda Tech Hub',
      description: 'Part-time internship researching student engagement patterns across ALU campuses.',
      campus: 'Kigali',
      category: 'Internship',
      host: 'Rwanda Tech Hub',
      deadline: 'Jul 30, 2026',
      attendeeCount: 34,
      tags: ['INTERNSHIP'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FeedItem(
      id: 'opp-2',
      type: FeedItemType.opportunity,
      title: 'Google Tech Internship 2026',
      description: 'Applications open for ALU students pursuing software engineering roles.',
      campus: 'All Campuses',
      category: 'Internship',
      host: 'ALU Career Services',
      deadline: 'Aug 15, 2026',
      attendeeCount: 89,
      tags: ['INTERNSHIP', 'FELLOWSHIP'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FeedItem(
      id: 'opp-3',
      type: FeedItemType.opportunity,
      title: 'Pan-African Leadership Fellowship',
      description: 'Six-month fellowship for students driving community impact projects.',
      campus: 'All Campuses',
      category: 'Leadership',
      host: 'ALU Leadership Lab',
      deadline: 'Jul 12, 2026',
      attendeeCount: 45,
      tags: ['FELLOWSHIP', 'COMPETITION'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    FeedItem(
      id: 'evt-4',
      type: FeedItemType.event,
      title: 'Design Thinking Masterclass',
      description: 'Learn human-centered design for campus ventures with ALU faculty.',
      campus: 'Mauritius',
      category: 'Workshop',
      host: 'ALU Design Society',
      date: 'Aug 5, 2026',
      time: '03:00 PM',
      location: 'Design Studio B',
      attendeeCount: 32,
      cohortMatches: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    FeedItem(
      id: 'evt-5',
      type: FeedItemType.event,
      title: 'Founders Networking Night',
      description: 'Meet student founders building across fintech, edtech, and health.',
      campus: 'Kigali',
      category: 'Social',
      host: 'ALU Entrepreneurs Network',
      date: 'Jul 28, 2026',
      time: '06:00 PM',
      location: 'Leadership Lab',
      attendeeCount: 48,
      cohortMatches: 6,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  static final clubs = [
    const Club(
      id: 'club-1',
      name: 'ALU Debate Society',
      description: 'Sharpen argumentation and public speaking across campuses.',
      iconName: 'gavel',
      memberCount: 150,
      campus: 'All Campuses',
    ),
    const Club(
      id: 'club-2',
      name: 'ALU Entrepreneurship Club',
      description: 'Build ventures with peer founders and industry mentors.',
      iconName: 'lightbulb',
      memberCount: 210,
      campus: 'Kigali',
    ),
    const Club(
      id: 'club-3',
      name: 'AI & Data Science Hub',
      description: 'Collaborate on ML projects, hackathons, and research.',
      iconName: 'psychology',
      memberCount: 142,
      campus: 'Kigali',
    ),
    const Club(
      id: 'club-4',
      name: 'Kigali Tech Hub',
      description: 'Campus tech community for builders and innovators.',
      iconName: 'code',
      memberCount: 98,
      campus: 'Kigali',
    ),
    const Club(
      id: 'club-5',
      name: 'ALU Design Society',
      description: 'UX, product design, and creative workshops.',
      iconName: 'brush',
      memberCount: 76,
      campus: 'Mauritius',
    ),
    const Club(
      id: 'club-6',
      name: 'Intercampus Summit Committee',
      description: 'Organize the annual cross-campus leadership summit.',
      iconName: 'public',
      memberCount: 45,
      campus: 'Virtual Hub',
    ),
  ];

  static final chatThreads = [
    const ChatThread(
      id: 'chat-1',
      name: 'AI & Data Science Hub',
      type: ChatType.group,
      lastMessage: 'Sandrine U.: Here\'s the refined strategy document...',
      timestamp: '14:20',
      avatarEmoji: '🤖',
      unreadCount: 3,
      memberCount: 142,
      onlineCount: 12,
    ),
    const ChatThread(
      id: 'chat-2',
      name: 'Kigali Tech Hub',
      type: ChatType.group,
      lastMessage: 'New hackathon team forming — who\'s in?',
      timestamp: 'Yesterday',
      avatarEmoji: '💻',
      unreadCount: 0,
      memberCount: 98,
      onlineCount: 8,
      isOnline: true,
    ),
    const ChatThread(
      id: 'chat-3',
      name: 'Keza Mutesi',
      type: ChatType.peer,
      lastMessage: 'Typing...',
      timestamp: '09:15',
      avatarEmoji: '👩🏾',
      unreadCount: 1,
      isTyping: true,
      isOnline: true,
    ),
    const ChatThread(
      id: 'chat-4',
      name: 'Eric Ntwali',
      type: ChatType.peer,
      lastMessage: 'You: I\'ll share the repo link tonight',
      timestamp: 'Jun 8',
      avatarEmoji: '👨🏿',
      unreadCount: 0,
    ),
    const ChatThread(
      id: 'chat-5',
      name: 'Intercampus Summit 2026',
      type: ChatType.group,
      lastMessage: 'Schedule for Day 2 is now live',
      timestamp: 'Jun 5',
      avatarEmoji: '🌍',
      unreadCount: 0,
      memberCount: 65,
      onlineCount: 3,
    ),
  ];

  static final chatMessages = [
    const ChatMessage(
      id: 'msg-1',
      threadId: 'chat-1',
      senderName: 'Jean Claude Uwimana',
      content:
          'Has anyone reviewed the GPT-4o API docs for our campus automation project?',
      timestamp: '09:42 AM',
    ),
    const ChatMessage(
      id: 'msg-2',
      threadId: 'chat-1',
      senderName: 'You',
      content:
          'Yes! I think we can adapt it for the ALU Porter Bot luggage identification feature.',
      timestamp: '09:45 AM',
      isMine: true,
      isRead: true,
    ),
    const ChatMessage(
      id: 'msg-3',
      threadId: 'chat-1',
      senderName: 'Sandrine Uwase',
      content: 'Here\'s the refined strategy document for the upcoming Hackathon...',
      timestamp: '09:48 AM',
      attachmentName: 'Campus_AI_strategy.pdf',
      attachmentSize: '2.4 MB • PDF',
    ),
    const ChatMessage(
      id: 'msg-4',
      threadId: 'chat-3',
      senderName: 'Keza Mutesi',
      content: 'Are you joining the Leadership Lab session tomorrow?',
      timestamp: '09:10 AM',
    ),
    const ChatMessage(
      id: 'msg-5',
      threadId: 'chat-4',
      senderName: 'Eric Ntwali',
      content: 'Can you review my pitch deck before the founders night?',
      timestamp: 'Jun 8',
    ),
    const ChatMessage(
      id: 'msg-6',
      threadId: 'chat-4',
      senderName: 'You',
      content: 'I\'ll share the repo link tonight',
      timestamp: 'Jun 8',
      isMine: true,
      isRead: true,
    ),
  ];

  static const quickReplies = [
    'Meet at Leadership Lab?',
    'Check repo 🔗',
    'Great work!',
    'On my way',
  ];
}

class UserProfilePlaceholder {
  const UserProfilePlaceholder({
    required this.name,
    required this.email,
    required this.campus,
    required this.cohort,
  });

  final String name;
  final String email;
  final String campus;
  final String cohort;
}
