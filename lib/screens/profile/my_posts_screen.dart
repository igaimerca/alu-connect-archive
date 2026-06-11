import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/feed_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/cards/feed_item_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/fade_in_item.dart';
import '../events/event_detail_screen.dart';
import 'edit_post_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, FeedItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text(
          '"${item.title}" will be removed permanently. RSVPs and saves for this post will also be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<FeedProvider>().deleteFeedItem(item.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final feed = context.watch<FeedProvider>();
    final posts =
        user != null ? feed.itemsByHost(user.name) : <FeedItem>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: posts.isEmpty
          ? EmptyState(
              icon: Icons.post_add_outlined,
              title: 'No posts yet',
              subtitle: user?.canPost == true
                  ? 'Events and opportunities you publish will appear here.'
                  : 'Only organizers can create posts. Sign in with your ALU account to publish.',
              actionLabel: user?.canPost == true ? 'Create a post' : null,
              onAction: user?.canPost == true
                  ? () {
                      Navigator.pop(context);
                      context.read<NavigationProvider>().setIndex(2);
                    }
                  : null,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final item = posts[i];
                return FadeInItem(
                  index: i,
                  child: Column(
                    children: [
                      FeedItemCard(
                        item: item,
                        onTap: () => pushFadeSlide(
                          context,
                          EventDetailScreen(itemId: item.id),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => pushFadeSlide(
                              context,
                              EditPostScreen(item: item),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmDelete(context, item),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
