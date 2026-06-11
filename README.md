# ALU Connect

Mobile-first student engagement platform for the African Leadership University ecosystem.

## Run

```bash
cd alu_connect
flutter pub get
flutter run
```

Use an iOS Simulator or Android emulator - not web.

## Demo accounts

`student@alueducation.com` - Organizer

## Features

- **Onboarding** - 3-slide intro with skip
- **Authentication** - SSO, social, email/password with validation
- **Home feed** - featured events, opportunities, category filters
- **Explore** - search, filters, campus discovery, My RSVPs, Clubs
- **RSVP** - Going / Interested with persisted state (SQLite)
- **Create post** - Event/Opportunity form with validation, cover image, date/time pickers (role-gated)
- **Edit / delete posts** - organizers manage their own posts from My Posts or event detail
- **Chats** - thread list, filters, group/peer detail, quick replies, send messages
- **Profile** - My Posts, Saved, Notifications, Help & Support (`support@aluconnect.com`), edit profile, sign out

## Tech Stack (Flutter and SQlite)

- **SQLite (sqflite)** - mock seed data, feed, RSVPs, clubs, chats, messages, saved items
- **SharedPreferences** - onboarding flag, auth session, user profile
- **Provider** - app-wide state management
- **Reusable widgets** - buttons, cards, chips, empty states

## Project structure

```
lib/
├── main.dart / app.dart
├── core/theme/          # Colors, ThemeData
├── core/constants/
├── data/
│   ├── models/
│   ├── mock/
│   ├── database/      SQLite (app data)
│   └── local/         SharedPreferences (auth session)
├── providers/
├── screens/
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── explore/
│   ├── events/
│   ├── clubs/
│   ├── create/
│   ├── chats/
│   └── profile/
└── widgets/
    ├── common/
    ├── cards/
    └── navigation/
```

## Team (5 members)

Aime · Aurele · Emmanuel · Mildred · Shakira