import 'package:flutter/foundation.dart';

import '../data/database/database_helper.dart';
import '../data/models/club.dart';

class ClubProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Club> _clubs = [];
  String _tab = 'All Clubs';
  String _searchQuery = '';
  bool _isLoading = true;

  List<Club> get clubs => _clubs;
  String get tab => _tab;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Club> get filteredClubs {
    var result = List<Club>.from(_clubs);

    if (_tab == 'My Clubs') {
      result = result.where((c) => c.isJoined).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  int get joinedCount => _clubs.where((c) => c.isJoined).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _clubs = await _db.getClubs();
    _isLoading = false;
    notifyListeners();
  }

  void setTab(String tab) {
    _tab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleJoin(String clubId) async {
    final index = _clubs.indexWhere((c) => c.id == clubId);
    if (index == -1) return;

    final club = _clubs[index];
    final newJoined = !club.isJoined;

    await _db.toggleClubJoin(clubId, newJoined);
    _clubs = await _db.getClubs();
    notifyListeners();
  }
}
