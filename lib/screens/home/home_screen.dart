import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/feed_item.dart';
import '../../providers/club_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/cards/club_card.dart';
import '../../widgets/cards/featured_event_card.dart';
import '../../widgets/cards/feed_item_card.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/fade_in_item.dart';
import '../events/event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'All';

  void _selectCategory(String category) {
    setState(() => _category = category);
    context.read<FeedProvider>().setFilter(category);
  }

  void _seeAll(String filter) {
    context.read<FeedProvider>().setFilter(filter);
    context.read<NavigationProvider>().setIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final clubs = context.watch<ClubProvider>();

    if (feed.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    final events = feed.items.where((i) => i.isEvent).toList();
    final allOpportunities = feed.items
        .where((i) => i.type == FeedItemType.opportunity)
        .toList();
    final featuredEvents =
        events.where((i) => i.isFeatured).take(3).toList();
    final upcomingEvents =
        events.where((i) => !i.isFeatured).take(4).toList();
    final previewOpportunities = allOpportunities.take(4).toList();
    final previewClubs = clubs.clubs.take(4).toList();

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          await Future.wait([feed.load(), clubs.load()]);
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: AppHeader(showGreeting: true)),
            SliverToBoxAdapter(child: _buildCategoryBar()),
            ..._buildCategoryContent(
              events: events,
              featuredEvents: featuredEvents,
              upcomingEvents: upcomingEvents,
              allOpportunities: allOpportunities,
              previewOpportunities: previewOpportunities,
              allClubs: clubs.clubs,
              previewClubs: previewClubs,
              clubsLoading: clubs.isLoading,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 88,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _CategoryIcon(
              label: 'All',
              icon: Icons.grid_view_rounded,
              selected: _category == 'All',
              onTap: () => _selectCategory('All'),
            ),
            _CategoryIcon(
              label: 'Events',
              icon: Icons.event_rounded,
              selected: _category == 'Events',
              onTap: () => _selectCategory('Events'),
            ),
            _CategoryIcon(
              label: 'Opportunities',
              icon: Icons.work_outline_rounded,
              selected: _category == 'Opportunities',
              onTap: () => _selectCategory('Opportunities'),
            ),
            _CategoryIcon(
              label: 'Clubs',
              icon: Icons.groups_rounded,
              selected: _category == 'Clubs',
              onTap: () => _selectCategory('Clubs'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryContent({
    required List<FeedItem> events,
    required List<FeedItem> featuredEvents,
    required List<FeedItem> upcomingEvents,
    required List<FeedItem> allOpportunities,
    required List<FeedItem> previewOpportunities,
    required List allClubs,
    required List previewClubs,
    required bool clubsLoading,
  }) {
    switch (_category) {
      case 'Events':
        return _buildEventsOnly(events);
      case 'Opportunities':
        return _buildOpportunitiesOnly(allOpportunities);
      case 'Clubs':
        return _buildClubsOnly(allClubs, clubsLoading);
      case 'All':
      default:
        return _buildAllSections(
          featuredEvents: featuredEvents,
          upcomingEvents: upcomingEvents,
          opportunities: previewOpportunities,
          popularClubs: previewClubs,
          clubsLoading: clubsLoading,
        );
    }
  }

  List<Widget> _buildAllSections({
    required List<FeedItem> featuredEvents,
    required List<FeedItem> upcomingEvents,
    required List<FeedItem> opportunities,
    required List popularClubs,
    required bool clubsLoading,
  }) {
    final slivers = <Widget>[];

    if (featuredEvents.isNotEmpty) {
      slivers.addAll(_featuredEventsCarousel(featuredEvents));
    }

    if (upcomingEvents.isNotEmpty) {
      slivers.addAll(
        _feedListSection(
          title: 'Upcoming Events',
          items: upcomingEvents,
          seeAllFilter: 'Events',
        ),
      );
    }

    if (opportunities.isNotEmpty) {
      slivers.addAll(
        _feedListSection(
          title: 'Latest Opportunities',
          items: opportunities,
          seeAllFilter: 'Opportunities',
        ),
      );
    }

    if (clubsLoading) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          ),
        ),
      );
    } else if (popularClubs.isNotEmpty) {
      slivers.addAll(_clubsSection(popularClubs));
    }

    if (slivers.isEmpty) {
      slivers.add(
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.explore_outlined,
            title: 'Nothing here yet',
            subtitle: 'Pull to refresh or check back for campus updates.',
          ),
        ),
      );
    }

    return slivers;
  }

  List<Widget> _buildEventsOnly(List<FeedItem> events) {
    if (events.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'No upcoming events',
            subtitle: 'Check back soon for workshops, summits, and meetups.',
          ),
        ),
      ];
    }

    return _feedListSection(
      title: 'Upcoming Events',
      items: events,
      seeAllFilter: 'Events',
      topPadding: 16,
    );
  }

  List<Widget> _buildOpportunitiesOnly(List<FeedItem> opportunities) {
    if (opportunities.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.work_off_outlined,
            title: 'No opportunities yet',
            subtitle: 'New internships and fellowships will appear here.',
          ),
        ),
      ];
    }

    return _feedListSection(
      title: 'Latest Opportunities',
      items: opportunities,
      seeAllFilter: 'Opportunities',
      topPadding: 16,
    );
  }

  List<Widget> _buildClubsOnly(List popularClubs, bool clubsLoading) {
    if (clubsLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
      ];
    }

    if (popularClubs.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.groups_outlined,
            title: 'No clubs found',
            subtitle: 'Student communities will show up here soon.',
          ),
        ),
      ];
    }

    return _clubsSection(popularClubs, topPadding: 16);
  }

  List<Widget> _featuredEventsCarousel(List<FeedItem> featuredEvents) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Events',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => _seeAll('Events'),
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppColors.gold),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 296,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: featuredEvents.length,
            itemBuilder: (_, i) {
              final item = featuredEvents[i];
              return FadeInItem(
                index: i,
                child: FeaturedEventCard(
                  item: item,
                  onTap: () => _openDetail(context, item.id),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _feedListSection({
    required String title,
    required List<FeedItem> items,
    required String seeAllFilter,
    double topPadding = 8,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, topPadding, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              if (_category == 'All')
                TextButton(
                  onPressed: () => _seeAll(seeAllFilter),
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => FadeInItem(
              index: i,
              child: FeedItemCard(
                item: items[i],
                onTap: () => _openDetail(context, items[i].id),
              ),
            ),
            childCount: items.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _clubsSection(List popularClubs, {double topPadding = 8}) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, topPadding, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campus Clubs',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              if (_category == 'All')
                TextButton(
                  onPressed: () => _seeAll('Clubs'),
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppColors.gold),
                  ),
                ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final club = popularClubs[i];
              return FadeInItem(
                index: i,
                child: ClubCard(
                  club: club,
                  onToggleJoin: () =>
                      context.read<ClubProvider>().toggleJoin(club.id),
                ),
              );
            },
            childCount: popularClubs.length,
          ),
        ),
      ),
    ];
  }

  void _openDetail(BuildContext context, String id) {
    pushFadeSlide(context, EventDetailScreen(itemId: id));
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? AppColors.gold : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.border,
                ),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.black : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.15,
                color: selected ? AppColors.gold : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
