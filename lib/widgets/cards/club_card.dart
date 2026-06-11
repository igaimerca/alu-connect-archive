import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/club.dart';
import '../common/outlined_gold_button.dart';

class ClubCard extends StatelessWidget {
  const ClubCard({
    super.key,
    required this.club,
    required this.onToggleJoin,
  });

  final Club club;
  final VoidCallback onToggleJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.surfaceLight,
            child: Icon(_iconForName(club.iconName), color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${club.memberCount} members',
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
          club.isJoined
              ? OutlinedGoldButton(
                  label: 'Joined',
                  compact: true,
                  onPressed: onToggleJoin,
                )
              : SizedBox(
                  height: 36,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggleJoin,
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Center(
                            child: Text(
                              'Join',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  IconData _iconForName(String name) {
    switch (name) {
      case 'gavel':
        return Icons.gavel_rounded;
      case 'lightbulb':
        return Icons.lightbulb_outline_rounded;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'code':
        return Icons.code_rounded;
      case 'brush':
        return Icons.brush_outlined;
      case 'public':
        return Icons.public_rounded;
      default:
        return Icons.groups_rounded;
    }
  }
}
