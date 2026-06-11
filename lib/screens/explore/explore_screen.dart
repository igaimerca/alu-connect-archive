import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/club_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/cards/feed_item_card.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/filter_chips_row.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/explore/campus_selector.dart';
import '../clubs/clubs_tab.dart';
import '../events/event_detail_screen.dart';
import '../events/my_rsvps_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onExploreTabChanged);
  }

  void _onExploreTabChanged() {
    if (_tabController.index != 1 || _tabController.indexIsChanging) return;
    context.read<FeedProvider>().load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onExploreTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();

    return SafeArea(
      child: Column(
        children: [
          const AppHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchField(
              hint: 'Search events, clubs, or peers...',
              controller: _searchController,
              onChanged: (q) {
                feed.setSearchQuery(q);
                context.read<ClubProvider>().setSearchQuery(q);
              },
            ),
          ),
          const SizedBox(height: 14),
          const CampusSelector(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilterChipsRow(
              options: AppStrings.feedFilters,
              selected: feed.filter,
              onSelected: feed.setFilter,
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'Discover'),
              Tab(text: 'My RSVPs'),
              Tab(text: 'Clubs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DiscoverTab(
                  items: feed.filteredItems,
                  onTap: (id) =>
                      pushFadeSlide(context, EventDetailScreen(itemId: id)),
                  onClearFilters: () {
                    feed.setSearchQuery('');
                    feed.setFilter('All');
                    feed.setCampusFilter(null);
                    _searchController.clear();
                  },
                ),
                MyRsvpsScreen(
                  embedded: true,
                  onExplore: () => _tabController.animateTo(0),
                ),
                const ClubsTab(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab({
    required this.items,
    required this.onTap,
    required this.onClearFilters,
  });

  final List items;
  final ValueChanged<String> onTap;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: feed.campusFilter != null
            ? 'Nothing on ${feed.campusFilter} campus with these filters.'
            : 'Try a different search or filter.',
        actionLabel: 'Clear filters',
        onAction: onClearFilters,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (feed.filter == 'All' && feed.campusFilter == null) ...[
          _FeaturedBanner(
            onTap: () {
              if (feed.featuredItems.isNotEmpty) {
                onTap(feed.featuredItems.first.id);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              feed.campusFilter != null
                  ? '${feed.campusFilter} campus'
                  : 'Recommended for you',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${items.length} results',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => FeedItemCard(
            item: item,
            onTap: () => onTap(item.id),
          ),
        ),
      ],
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.2),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 12,
              left: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    'Featured',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Text(
                'Intercampus Tech Summit 2026',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
