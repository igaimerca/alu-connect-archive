import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/feed_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../profile/edit_post_screen.dart';
import '../../widgets/common/date_time_widget.dart';
import '../../widgets/common/feed_cover_image.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/outlined_gold_button.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final user = context.watch<AuthProvider>().user;
    final item = feed.getById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('This item could not be found.')),
      );
    }

    final status = feed.getRsvpStatus(itemId);
    final isSaved = feed.savedIds.contains(itemId);
    final isOwner =
        user != null && feed.isOwnedBy(itemId, user.name);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FeedCoverImage(
                imagePath: item.imageUrl,
                iconSize: 72,
              ),
            ),
            actions: [
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.gold),
                  onSelected: (action) async {
                    if (action == 'edit') {
                      pushFadeSlide(
                        context,
                        EditPostScreen(item: item),
                      );
                    } else if (action == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete post?'),
                          content: const Text(
                            'This post will be removed permanently.',
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
                        await feed.deleteFeedItem(itemId);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post deleted')),
                        );
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit post'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete post',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: AppColors.gold,
                ),
                onPressed: () {
                  feed.toggleSaved(itemId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSaved ? 'Removed from saved' : 'Saved!'),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: item.tags
                        .map((t) => Chip(
                              label: Text(t),
                              backgroundColor: t == item.tags.first
                                  ? AppColors.gold
                                  : AppColors.surfaceLight,
                              labelStyle: TextStyle(
                                color: t == item.tags.first
                                    ? Colors.black
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hosted by ${item.host}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  AluDateTimeDisplay(
                    date: item.date,
                    time: item.time,
                    endTime: item.endTime,
                    deadline: item.deadline,
                    style: AluDateTimeDisplayStyle.detail,
                  ),
                  if (item.isEvent) ...[
                    const SizedBox(height: 10),
                    _DetailCard(
                      icon: Icons.location_on_outlined,
                      title: item.campus,
                      subtitle: item.location,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    item.isEvent ? 'About this event' : 'About this opportunity',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (item.cohortMatches > 0) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'WHO\'S GOING',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ...List.generate(
                          4,
                          (i) => Transform.translate(
                            offset: Offset(i * -10.0, 0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.surfaceLight,
                              child: Text('${i + 1}'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '+${item.attendeeCount - 4} others including ${item.cohortMatches} from your cohort',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: item.isEvent
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: status == RsvpStatus.going ? 'Going ✓' : 'RSVP',
                      icon: Icons.check_circle_outline,
                      height: 48,
                      onPressed: () async {
                        final newStatus = status == RsvpStatus.going
                            ? RsvpStatus.none
                            : RsvpStatus.going;
                        await feed.setRsvp(itemId, newStatus);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newStatus == RsvpStatus.going
                                  ? 'You\'re going! See you there.'
                                  : 'RSVP cancelled.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedGoldButton(
                      label: status == RsvpStatus.interested
                          ? 'Interested ★'
                          : 'Interested',
                      icon: Icons.star_outline_rounded,
                      onPressed: () async {
                        final newStatus = status == RsvpStatus.interested
                            ? RsvpStatus.none
                            : RsvpStatus.interested;
                        await feed.setRsvp(itemId, newStatus);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              newStatus == RsvpStatus.interested
                                  ? 'Marked as interested.'
                                  : 'Removed from interested.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
