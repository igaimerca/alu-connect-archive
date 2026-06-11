import 'package:flutter/foundation.dart';

import '../data/local/preferences_service.dart';
import '../data/mock/mock_data.dart';
import '../data/models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._prefs);

  final PreferencesService _prefs;

  bool _isLoading = true;
  bool _onboardingComplete = false;
  bool _isLoggedIn = false;
  UserProfile? _user;

  bool get isLoading => _isLoading;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoggedIn => _isLoggedIn;
  UserProfile? get user => _user;

  Future<void> initialize() async {
    _onboardingComplete = await _prefs.isOnboardingComplete();
    _isLoggedIn = await _prefs.isLoggedIn();
    _user = await _prefs.getUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await _prefs.setOnboardingComplete(true);
    notifyListeners();
  }

  Future<String?> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Please enter your email and password.';
    }
    if (!email.contains('@')) {
      return 'Enter a valid ALU email address.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    final placeholder = MockData.defaultUser;
    _user = UserProfile(
      id: 'user-1',
      name: placeholder.name,
      email: email.trim(),
      campus: placeholder.campus,
      cohort: placeholder.cohort,
      bio: 'Passionate about leadership, tech, and community building at ALU.',
      eventsCount: 12,
      communitiesCount: 5,
      connectionsCount: 84,
      canPost: email.contains('leader') ||
          email.contains('organizer') ||
          email.contains('patrick'),
    );

    _isLoggedIn = true;
    await _prefs.setLoggedIn(true);
    await _prefs.saveUser(_user!);
    notifyListeners();
    return null;
  }

  Future<String?> signInWithSso() async {
    return signIn(
      email: 'patrick.mugisha@alueducation.com',
      password: 'alu2026',
    );
  }

  Future<void> signOut() async {
    _isLoggedIn = false;
    _user = null;
    await _prefs.clearSession();
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? campus, String? bio}) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: name, campus: campus, bio: bio);
    await _prefs.saveUser(_user!);
    notifyListeners();
  }
}
