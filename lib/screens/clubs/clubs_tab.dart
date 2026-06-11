import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/club_provider.dart';
import '../../widgets/cards/club_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/search_field.dart';

class ClubsTab extends StatefulWidget {
  const ClubsTab({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ClubsTab> createState() => _ClubsTabState();
}

class _ClubsTabState extends State<ClubsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubs = context.watch<ClubProvider>();

    if (clubs.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: _ClubTabBar(
            tab: clubs.tab,
            onChanged: clubs.setTab,
          ),
        ),
        if (!widget.embedded)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SearchField(
              hint: 'Search clubs...',
              controller: _searchController,
              onChanged: clubs.setSearchQuery,
            ),
          ),
        Expanded(
          child: clubs.filteredClubs.isEmpty
              ? EmptyState(
                  icon: Icons.groups_outlined,
                  title: clubs.tab == 'My Clubs'
                      ? 'No clubs joined yet'
                      : 'No clubs found',
                  subtitle: clubs.tab == 'My Clubs'
                      ? 'Browse All Clubs and join communities.'
                      : 'Try a different search term.',
                  actionLabel:
                      clubs.tab == 'My Clubs' ? 'Browse clubs' : null,
                  onAction: clubs.tab == 'My Clubs'
                      ? () => clubs.setTab('All Clubs')
                      : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: clubs.filteredClubs.length,
                  itemBuilder: (_, i) {
                    final club = clubs.filteredClubs[i];
                    return ClubCard(
                      club: club,
                      onToggleJoin: () async {
                        await clubs.toggleJoin(club.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              club.isJoined
                                  ? 'Left ${club.name}'
                                  : 'Joined ${club.name}!',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) return content;

    return SafeArea(child: content);
  }
}

class _ClubTabBar extends StatelessWidget {
  const _ClubTabBar({required this.tab, required this.onChanged});

  final String tab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['All Clubs', 'My Clubs'].map((t) {
        final selected = tab == t;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t),
            child: Column(
              children: [
                Text(
                  t,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        selected ? AppColors.gold : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
