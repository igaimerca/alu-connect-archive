import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/feed_provider.dart';

class CampusInfo {
  const CampusInfo({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    this.gradientColors,
  });

  final String? id;
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
}

const _campuses = [
  CampusInfo(
    id: null,
    label: 'All Campuses',
    subtitle: 'Everywhere at ALU',
    icon: Icons.public_rounded,
    gradientColors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  ),
  CampusInfo(
    id: 'Kigali',
    label: 'Kigali',
    subtitle: 'Rwanda hub',
    icon: Icons.location_city_rounded,
    gradientColors: [Color(0xFF3D2E14), Color(0xFF1A2332)],
  ),
  CampusInfo(
    id: 'Mauritius',
    label: 'Mauritius',
    subtitle: 'Island campus',
    icon: Icons.waves_rounded,
    gradientColors: [Color(0xFF14303D), Color(0xFF1A2332)],
  ),
  CampusInfo(
    id: 'Virtual Hub',
    label: 'Virtual Hub',
    subtitle: 'Online & remote',
    icon: Icons.laptop_mac_rounded,
    gradientColors: [Color(0xFF2D1F4E), Color(0xFF1A2332)],
  ),
];

class CampusSelector extends StatelessWidget {
  const CampusSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final allItems = feed.items;

    int countFor(CampusInfo campus) {
      if (campus.id == null) return allItems.length;
      return allItems
          .where((i) => i.campus == campus.id || i.campus == 'All Campuses')
          .length;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Explore by Campus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Filter events and opportunities by ALU campus',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: _campuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final campus = _campuses[i];
                final selected = feed.campusFilter == campus.id;
                return _CampusTile(
                  campus: campus,
                  count: countFor(campus),
                  selected: selected,
                  onTap: () {
                    if (campus.id == null) {
                      feed.setCampusFilter(null);
                    } else if (selected) {
                      feed.setCampusFilter(null);
                    } else {
                      feed.setCampusFilter(campus.id);
                    }
                  },
                );
              },
            ),
          ),
          if (feed.campusFilter != null) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, color: AppColors.gold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing ${feed.campusFilter} campus',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => feed.setCampusFilter(null),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.close, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CampusTile extends StatelessWidget {
  const _CampusTile({
    required this.campus,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final CampusInfo campus;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: campus.gradientColors ??
                [AppColors.surfaceLight, AppColors.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  campus.icon,
                  color: selected ? AppColors.gold : AppColors.textSecondary,
                  size: 22,
                ),
                const Spacer(),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: AppColors.gold, size: 18),
              ],
            ),
            const Spacer(),
            Text(
              campus.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? AppColors.gold : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
