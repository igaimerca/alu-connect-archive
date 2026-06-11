import 'package:alu_connect/app.dart';
import 'package:alu_connect/data/local/preferences_service.dart';
import 'package:alu_connect/providers/auth_provider.dart';
import 'package:alu_connect/providers/chat_provider.dart';
import 'package:alu_connect/providers/club_provider.dart';
import 'package:alu_connect/providers/feed_provider.dart';
import 'package:alu_connect/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App loads onboarding or login gate', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(PreferencesService()),
          ),
          ChangeNotifierProvider(create: (_) => FeedProvider()),
          ChangeNotifierProvider(create: (_) => ClubProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: const AluConnectApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
