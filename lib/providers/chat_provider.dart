import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/database/database_helper.dart';
import '../data/mock/mock_data.dart';
import '../data/models/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  List<ChatThread> _threads = [];
  final Map<String, List<ChatMessage>> _messages = {};
  String _filter = 'All Chats';
  bool _isLoading = true;

  List<ChatThread> get threads => _threads;
  String get filter => _filter;
  bool get isLoading => _isLoading;

  List<ChatThread> get filteredThreads {
    if (_filter == 'Groups') {
      return _threads.where((t) => t.type == ChatType.group).toList();
    }
    if (_filter == 'Peers') {
      return _threads.where((t) => t.type == ChatType.peer).toList();
    }
    return _threads;
  }

  int get totalUnread =>
      _threads.fold(0, (sum, t) => sum + t.unreadCount);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _threads = await _db.getChatThreads();
    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<List<ChatMessage>> getMessages(String threadId) async {
    if (_messages.containsKey(threadId)) {
      return _messages[threadId]!;
    }
    final msgs = await _db.getMessages(threadId);
    _messages[threadId] = msgs;
    return msgs;
  }

  Future<void> sendMessage(String threadId, String content) async {
    if (content.trim().isEmpty) return;

    final now = DateFormat('hh:mm a').format(DateTime.now());
    final message = ChatMessage(
      id: _uuid.v4(),
      threadId: threadId,
      senderName: 'You',
      content: content.trim(),
      timestamp: now,
      isMine: true,
      isRead: true,
    );

    _messages.putIfAbsent(threadId, () => []).add(message);
    await _db.insertMessage(message);

    final threadIndex = _threads.indexWhere((t) => t.id == threadId);
    if (threadIndex != -1) {
      final updated = _threads[threadIndex].copyWith(
        lastMessage: 'You: ${content.trim()}',
        timestamp: now,
        unreadCount: 0,
        isTyping: false,
      );
      _threads[threadIndex] = updated;
      await _db.updateChatThread(updated);
    }

    notifyListeners();
  }

  Future<void> markThreadRead(String threadId) async {
    final index = _threads.indexWhere((t) => t.id == threadId);
    if (index == -1) return;
    if (_threads[index].unreadCount == 0) return;

    final updated = _threads[index].copyWith(unreadCount: 0, isTyping: false);
    _threads[index] = updated;
    await _db.updateChatThread(updated);
    notifyListeners();
  }

  List<String> get quickReplies => MockData.quickReplies;
}
