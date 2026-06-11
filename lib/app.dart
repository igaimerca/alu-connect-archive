import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/club_provider.dart';
import 'providers/feed_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'widgets/common/splash_screen.dart';
import 'widgets/navigation/main_shell.dart';

class AluConnectApp extends StatelessWidget {
  const AluConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALU Connect',
      theme: AppTheme.darkTheme,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final feed = context.read<FeedProvider>();
    final clubs = context.read<ClubProvider>();
    final chat = context.read<ChatProvider>();

    await auth.initialize();
    await Future.wait([
      feed.load(),
      clubs.load(),
      chat.load(),
    ]);
    if (mounted) setState(() => _dataLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading || !_dataLoaded) {
      return const SplashScreen();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: !auth.onboardingComplete
          ? const OnboardingScreen(key: ValueKey('onboarding'))
          : !auth.isLoggedIn
              ? const LoginScreen(key: ValueKey('login'))
              : const MainShell(key: ValueKey('main')),
    );
  }
}
