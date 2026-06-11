import 'package:flutter/material.dart';

import '../../data/models/feed_item.dart';
import '../create/create_post_screen.dart';

class EditPostScreen extends StatelessWidget {
  const EditPostScreen({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
      ),
      body: CreatePostScreen(editingItem: item),
    );
  }
}
