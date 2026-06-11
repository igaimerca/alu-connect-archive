import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/feed_item.dart';

class FeedProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<FeedItem> _items = [];
  Map<String, RsvpStatus> _rsvps = {};
  Set<String> _savedIds = {};
  String _filter = 'All';
  String _searchQuery = '';
  String? _campusFilter;
  bool _isLoading = true;

  List<FeedItem> get items => _items;
  Map<String, RsvpStatus> get rsvps => _rsvps;
  Set<String> get savedIds => _savedIds;
  String get filter => _filter;
  String get searchQuery => _searchQuery;
  String? get campusFilter => _campusFilter;
  bool get isLoading => _isLoading;

  List<FeedItem> get featuredItems =>
      _items.where((i) => i.isFeatured).take(3).toList();

  List<FeedItem> get filteredItems {
    var result = List<FeedItem>.from(_items);

    if (_filter == 'Events') {
      result = result.where((i) => i.isEvent).toList();
    } else if (_filter == 'Opportunities') {
      result = result.where((i) => i.type == FeedItemType.opportunity).toList();
    } else if (_filter == 'Clubs') {
      result = result.where((i) => i.type == FeedItemType.club).toList();
    }

    if (_campusFilter != null && _campusFilter!.isNotEmpty) {
      result = result
          .where((i) =>
              i.campus == _campusFilter ||
              i.campus == 'All Campuses')
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((i) =>
              i.title.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.host.toLowerCase().contains(q) ||
              i.campus.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  List<FeedItem> _itemsForRsvpStatus(RsvpStatus status) {
    return _rsvps.entries
        .where((entry) => entry.value == status)
        .map((entry) => getById(entry.key))
        .whereType<FeedItem>()
        .toList();
  }

  List<FeedItem> get goingItems => _itemsForRsvpStatus(RsvpStatus.going);

  List<FeedItem> get interestedItems =>
      _itemsForRsvpStatus(RsvpStatus.interested);

  int get goingCount => goingItems.length;

  int get interestedCount => interestedItems.length;

  List<FeedItem> get savedItems =>
      _items.where((i) => _savedIds.contains(i.id)).toList();

  List<FeedItem> itemsByHost(String hostName) =>
      _items.where((i) => i.host == hostName).toList();

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _items = await _db.getFeedItems();
    _rsvps = await _db.getAllRsvps();
    _savedIds = await _db.getSavedItemIds();

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCampusFilter(String? campus) {
    _campusFilter = campus;
    notifyListeners();
  }

  RsvpStatus getRsvpStatus(String itemId) =>
      _rsvps[itemId] ?? RsvpStatus.none;

  Future<void> setRsvp(String itemId, RsvpStatus status) async {
    final current = _rsvps[itemId] ?? RsvpStatus.none;
    if (current == status) return;

    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return;

    var item = _items[itemIndex];
    var count = item.attendeeCount;

    if (current == RsvpStatus.going) count--;
    if (status == RsvpStatus.going) count++;

    if (status == RsvpStatus.none) {
      _rsvps.remove(itemId);
    } else {
      _rsvps[itemId] = status;
    }

    item = item.copyWith(attendeeCount: count < 0 ? 0 : count);
    _items[itemIndex] = item;
    notifyListeners();

    await _db.setRsvpStatus(itemId, status);
    await _db.updateFeedItem(item);
  }

  Future<void> toggleSaved(String itemId) async {
    final isSaved = _savedIds.contains(itemId);
    if (isSaved) {
      _savedIds.remove(itemId);
    } else {
      _savedIds.add(itemId);
    }
    await _db.toggleSaved(itemId, !isSaved);
    notifyListeners();
  }

  Future<void> addFeedItem(FeedItem item) async {
    _items.insert(0, item);
    await _db.insertFeedItem(item);
    notifyListeners();
  }

  Future<void> updateFeedItem(FeedItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;
    _items[index] = item;
    await _db.updateFeedItem(item);
    notifyListeners();
  }

  Future<void> deleteFeedItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    _rsvps.remove(id);
    _savedIds.remove(id);
    await _db.deleteFeedItem(id);
    notifyListeners();
  }

  bool isOwnedBy(String itemId, String userName) {
    final item = getById(itemId);
    return item != null && item.host == userName;
  }

  FeedItem? getById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
