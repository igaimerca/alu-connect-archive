import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/page_transitions.dart';
import '../../providers/feed_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/cards/feed_item_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/fade_in_item.dart';
import '../events/event_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final saved = feed.savedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
      ),
      body: saved.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_outline,
              title: 'Nothing saved yet',
              subtitle:
                  'Tap the bookmark icon on any event or opportunity to save it here.',
              actionLabel: 'Explore',
              onAction: () {
                Navigator.pop(context);
                context.read<NavigationProvider>().setIndex(1);
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: saved.length,
              itemBuilder: (_, i) => FadeInItem(
                index: i,
                child: FeedItemCard(
                  item: saved[i],
                  onTap: () => pushFadeSlide(
                    context,
                    EventDetailScreen(itemId: saved[i].id),
                  ),
                ),
              ),
            ),
    );
  }
}
