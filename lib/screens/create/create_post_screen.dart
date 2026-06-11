import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/image_storage.dart';
import '../../data/models/feed_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/date_time_widget.dart';
import '../../widgets/common/gradient_button.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.editingItem});

  final FeedItem? editingItem;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _dateError;

  String _postType = 'Event';
  String? _campus;
  String? _category;
  String? _coverImagePath;
  bool _isPublishing = false;
  bool _isPickingImage = false;

  bool get _isEditing => widget.editingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.editingItem;
    if (item == null) return;

    _titleController.text = item.title;
    _descController.text = item.description;
    _postType = item.isEvent ? 'Event' : 'Opportunity';
    _campus = item.campus;
    _category = item.category;
    _coverImagePath = item.imageUrl.isNotEmpty ? item.imageUrl : null;
    _selectedDate = AluDateTimeFormatter.parseDate(
      item.deadline.isNotEmpty ? item.deadline : item.date,
    );
    _selectedTime = AluDateTimeFormatter.parseTime(item.time);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add cover image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.gold),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_outlined, color: AppColors.gold),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              if (_coverImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Remove image'),
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (action == null) return;

    if (action == 'remove') {
      setState(() => _coverImagePath = null);
      return;
    }

    final source =
        action == 'camera' ? ImageSource.camera : ImageSource.gallery;

    setState(() => _isPickingImage = true);
    try {
      final path = await ImageStorage.instance.pickAndSaveCover(source: source);
      if (!mounted) return;
      if (path != null) {
        setState(() => _coverImagePath = path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load image: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      setState(() => _dateError = 'Select a date');
      return;
    }

    if (_campus == null || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a campus and category.')),
      );
      return;
    }

    setState(() {
      _dateError = null;
      _isPublishing = true;
    });

    final formattedDate = AluDateTimeFormatter.formatDate(_selectedDate!);
    final formattedTime = _selectedTime != null
        ? AluDateTimeFormatter.formatTime(_selectedTime!)
        : '';

    final user = context.read<AuthProvider>().user;
    final feed = context.read<FeedProvider>();
    final existing = widget.editingItem;

    final item = existing != null
        ? existing.copyWith(
            type: _postType == 'Event'
                ? FeedItemType.event
                : FeedItemType.opportunity,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            campus: _campus ?? 'All Campuses',
            category: _category ?? 'Academic',
            imageUrl: _coverImagePath ?? '',
            date: formattedDate,
            time: formattedTime,
            deadline: _postType == 'Opportunity' ? formattedDate : '',
            tags: [_category ?? 'General'],
          )
        : FeedItem(
            id: const Uuid().v4(),
            type: _postType == 'Event'
                ? FeedItemType.event
                : FeedItemType.opportunity,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            campus: _campus ?? 'All Campuses',
            category: _category ?? 'Academic',
            host: user?.name ?? 'ALU Student',
            imageUrl: _coverImagePath ?? '',
            date: formattedDate,
            time: formattedTime,
            deadline: _postType == 'Opportunity' ? formattedDate : '',
            createdAt: DateTime.now(),
            tags: [_category ?? 'General'],
          );

    if (existing != null) {
      await feed.updateFeedItem(item);
    } else {
      await feed.addFeedItem(item);
    }

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );
      Navigator.pop(context);
      return;
    }

    _formKey.currentState!.reset();
    _titleController.clear();
    _descController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _dateError = null;
      _campus = null;
      _category = null;
      _coverImagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Published successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final feed = context.watch<FeedProvider>();
    final canPost = user?.canPost ?? false;

    if (_isEditing) {
      final owned = feed.isOwnedBy(widget.editingItem!.id, user?.name ?? '');
      if (!owned) {
        return const Center(child: Text('You can only edit your own posts.'));
      }
      return _buildForm();
    }

    return SafeArea(
      child: canPost
          ? _buildForm()
          : _UnauthorizedView(userName: user?.name ?? 'Student'),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.of(context).padding.bottom + 72,
        ),
        children: [
          if (!_isEditing) const AppHeader(),
          if (!_isEditing)
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['Event', 'Opportunity'].map((type) {
                final selected = _postType == type;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: type == 'Event' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _postType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.gold
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.black
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: _isEditing ? 12 : 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverImagePicker(
                  imagePath: _coverImagePath,
                  isLoading: _isPickingImage,
                  onTap: _pickCoverImage,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Post Title',
                    hintText: 'Enter a catchy title...',
                  ),
                  validator: (v) => v == null || v.trim().length < 5
                      ? 'Title must be at least 5 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Tell the community more about this...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.trim().length < 20
                      ? 'Description must be at least 20 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                AluDateTimePicker(
                  dateLabel:
                      _postType == 'Event' ? 'Date' : 'Application deadline',
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  showTime: _postType == 'Event',
                  errorText: _dateError,
                  onDateChanged: (date) => setState(() {
                    _selectedDate = date;
                    _dateError = null;
                  }),
                  onTimeChanged: (time) =>
                      setState(() => _selectedTime = time),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _campus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Campus Location',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  hint: const Text('Select a campus'),
                  items: AppStrings.campuses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _campus = v),
                  validator: (v) =>
                      v == null ? 'Select a campus' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppStrings.categories.map((cat) {
                    final selected = _category == cat;
                    return ChoiceChip(
                      label: Text(
                        cat,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: AppColors.gold,
                      labelStyle: TextStyle(
                        color: selected ? Colors.black : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                if (_category == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Tap a category above',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                GradientButton(
                  label: _isEditing ? 'Save changes' : 'Publish',
                  isLoading: _isPublishing,
                  onPressed: _publish,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.imagePath,
    required this.isLoading,
    required this.onTap,
  });

  final String? imagePath;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync();

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasImage ? AppColors.gold : AppColors.border,
            width: hasImage ? 1.5 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                ),
              )
            else
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.textMuted, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'Upload Cover Image',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to choose from gallery or camera',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
            if (hasImage && !isLoading)
              Positioned(
                top: 8,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Change',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.gold),
            const SizedBox(height: 16),
            const Text(
              'Posting requires organizer access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hi $userName — only club leaders, event organizers, and approved community hosts can publish. Request access from ALU Student Life.',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
