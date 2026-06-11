import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/feed_item.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/common/date_time_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'event_detail_screen.dart';

class MyRsvpsScreen extends StatefulWidget {
  const MyRsvpsScreen({
    super.key,
    this.embedded = false,
    this.onExplore,
  });

  final bool embedded;
  final VoidCallback? onExplore;

  @override
  State<MyRsvpsScreen> createState() => _MyRsvpsScreenState();
}

class _MyRsvpsScreenState extends State<MyRsvpsScreen>
    with AutomaticKeepAliveClientMixin {
  String _tab = 'Going';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final feed = context.watch<FeedProvider>();
    final items =
        _tab == 'Going' ? feed.goingItems : feed.interestedItems;

    final body = Column(
      children: [
        _TabBar(
          tab: _tab,
          goingCount: feed.goingCount,
          interestedCount: feed.interestedCount,
          onChanged: (t) => setState(() => _tab = t),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.gold,
            onRefresh: feed.load,
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: EmptyState(
                          icon: Icons.event_busy_outlined,
                          title: _tab == 'Going'
                              ? 'No events yet'
                              : 'Nothing marked interested',
                          subtitle: _tab == 'Going'
                              ? 'Open an event from Discover and tap RSVP or Going.'
                              : 'Open an event and tap Interested to track it here.',
                          actionLabel: 'Browse events',
                          onAction: widget.onExplore,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _RsvpCard(
                      item: items[i],
                      status: feed.getRsvpStatus(items[i].id),
                      onTap: () => pushFadeSlide(
                        context,
                        EventDetailScreen(itemId: items[i].id),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return SafeArea(child: body);
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tab,
    required this.goingCount,
    required this.interestedCount,
    required this.onChanged,
  });

  final String tab;
  final int goingCount;
  final int interestedCount;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _TabChip(
            label: 'Going',
            count: goingCount,
            selected: tab == 'Going',
            onTap: () => onChanged('Going'),
          ),
          const SizedBox(width: 10),
          _TabChip(
            label: 'Interested',
            count: interestedCount,
            selected: tab == 'Interested',
            onTap: () => onChanged('Interested'),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.black : AppColors.textPrimary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.black87 : AppColors.gold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RsvpCard extends StatelessWidget {
  const _RsvpCard({
    required this.item,
    required this.status,
    required this.onTap,
  });

  final FeedItem item;
  final RsvpStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event, color: AppColors.gold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: status == RsvpStatus.going
                          ? AppColors.success
                          : AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status == RsvpStatus.going ? 'GOING' : 'INTERESTED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: status == RsvpStatus.going
                            ? Colors.white
                            : AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        item.campus,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  AluDateTimeFormatter.shortDate(item.date),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Details >',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
