import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../chats/chat_detail_screen.dart';
import 'saved_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final feed = context.watch<FeedProvider>();
    final notifications = _buildNotifications(chat, feed);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'All caught up',
              subtitle:
                  'New RSVPs, messages, and campus updates will show here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return _NotificationTile(
                  icon: n.icon,
                  title: n.title,
                  body: n.body,
                  time: n.time,
                  unread: n.unread,
                  onTap: () => n.onTap(context),
                );
              },
            ),
    );
  }

  List<_NotificationItem> _buildNotifications(
    ChatProvider chat,
    FeedProvider feed,
  ) {
    final items = <_NotificationItem>[];

    for (final thread in chat.threads) {
      if (thread.unreadCount > 0) {
        items.add(
          _NotificationItem(
            icon: Icons.chat_bubble_outline,
            title: thread.name,
            body: thread.lastMessage,
            time: thread.timestamp,
            unread: true,
            onTap: (context) => pushFadeSlide(
              context,
              ChatDetailScreen(threadId: thread.id),
            ),
          ),
        );
      }
    }

    final going = feed.goingItems;
    if (going.isNotEmpty) {
      items.add(
        _NotificationItem(
          icon: Icons.event_available_outlined,
          title: 'Upcoming RSVP',
          body: 'You\'re going to "${going.first.title}"',
          time: going.first.date,
          onTap: (context) {
            Navigator.pop(context);
            context.read<NavigationProvider>().setIndex(1);
          },
        ),
      );
    }

    if (feed.savedItems.isNotEmpty) {
      items.add(
        _NotificationItem(
          icon: Icons.bookmark_outline,
          title: 'Saved items',
          body: '${feed.savedItems.length} bookmarked on your list',
          time: 'Recently',
          onTap: (context) => pushFadeSlide(context, const SavedScreen()),
        ),
      );
    }

    return items;
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final void Function(BuildContext context) onTap;
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread
                  ? AppColors.gold.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
