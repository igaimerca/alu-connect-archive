import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/club_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/outlined_gold_button.dart';
import '../../widgets/profile/help_support_sheet.dart';
import 'my_posts_screen.dart';
import 'notifications_screen.dart';
import 'saved_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final feed = context.watch<FeedProvider>();
    final clubs = context.watch<ClubProvider>();
    final chat = context.watch<ChatProvider>();

    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    final goingCount = feed.goingItems.length;
    final joinedCount = clubs.joinedCount;
    final unread = chat.totalUnread;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppHeader(
            trailing: IconButton(
              onPressed: () => _showEditProfile(context),
              icon: const Icon(Icons.settings_outlined, color: AppColors.gold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified,
                        size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text('${user.campus} Campus',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatCard(label: 'Events', value: '$goingCount'),
                const SizedBox(width: 10),
                _StatCard(label: 'Communities', value: '$joinedCount'),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Connections',
                  value: '${user.connectionsCount}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'ACCOUNT INFORMATION',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.post_add_outlined,
            title: 'My Posts',
            subtitle: '${feed.itemsByHost(user.name).length} published',
            onTap: () => pushFadeSlide(context, const MyPostsScreen()),
          ),
          _MenuTile(
            icon: Icons.bookmark_outline,
            title: 'Saved',
            subtitle: '${feed.savedItems.length} items',
            onTap: () => pushFadeSlide(context, const SavedScreen()),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: unread > 0 ? '$unread new updates' : null,
            onTap: () => pushFadeSlide(context, const NotificationsScreen()),
          ),
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Account Settings',
            onTap: () => _showEditProfile(context),
          ),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => showHelpSupportSheet(context),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedGoldButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign out?'),
                    content: const Text(
                      'You will need to sign in again to access your RSVPs and chats.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out',
                            style: TextStyle(color: AppColors.gold)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().signOut();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio);
    String campus = user.campus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: campus,
                decoration: const InputDecoration(labelText: 'Campus'),
                items: ['Kigali', 'Mauritius', 'Virtual Hub']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => campus = v ?? campus,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                ),
                onPressed: () async {
                  await context.read<AuthProvider>().updateProfile(
                        name: nameController.text.trim(),
                        campus: campus,
                        bio: bioController.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.gold),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: subtitle != null
              ? Text(subtitle!,
                  style: const TextStyle(color: AppColors.gold, fontSize: 12))
              : null,
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
