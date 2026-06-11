import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/cards/chat_thread_tile.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/filter_chips_row.dart';
import '../../widgets/common/search_field.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    if (chat.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    var threads = chat.filteredThreads;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      threads = threads
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.lastMessage.toLowerCase().contains(q))
          .toList();
    }

    return SafeArea(
      child: Column(
        children: [
          const AppHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchField(
              hint: 'Find peers or campus groups...',
              controller: _searchController,
              onChanged: (q) => setState(() => _query = q),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilterChipsRow(
              options: AppStrings.chatFilters,
              selected: chat.filter,
              onSelected: chat.setFilter,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: threads.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No conversations',
                    subtitle: _query.isNotEmpty
                        ? 'No chats match your search.'
                        : 'Join clubs and events to start chatting.',
                  )
                : ListView.builder(
                    itemCount: threads.length,
                    itemBuilder: (_, i) {
                      final thread = threads[i];
                      return ChatThreadTile(
                        thread: thread,
                        onTap: () async {
                          await chat.markThreadRead(thread.id);
                          if (!context.mounted) return;
                          pushFadeSlide(
                            context,
                            ChatDetailScreen(threadId: thread.id),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
