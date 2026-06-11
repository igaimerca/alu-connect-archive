import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_models.dart';
import '../models/club.dart';
import '../models/feed_item.dart';
import '../mock/mock_data.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alu_connect.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.delete('chat_messages');
          await db.delete('chat_threads');
          for (final thread in MockData.chatThreads) {
            await db.insert('chat_threads', thread.toMap());
          }
          for (final message in MockData.chatMessages) {
            await db.insert('chat_messages', message.toMap());
          }
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
        await db.execute('''
          CREATE TABLE feed_items (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            campus TEXT NOT NULL,
            category TEXT NOT NULL,
            host TEXT NOT NULL,
            imageUrl TEXT,
            date TEXT,
            time TEXT,
            endTime TEXT,
            location TEXT,
            deadline TEXT,
            attendeeCount INTEGER DEFAULT 0,
            cohortMatches INTEGER DEFAULT 0,
            isFeatured INTEGER DEFAULT 0,
            tags TEXT,
            memberCount INTEGER DEFAULT 0,
            createdAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE rsvps (
            itemId TEXT PRIMARY KEY,
            status TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE clubs (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            iconName TEXT,
            memberCount INTEGER DEFAULT 0,
            campus TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE joined_clubs (
            clubId TEXT PRIMARY KEY
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_threads (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            lastMessage TEXT,
            timestamp TEXT,
            avatarEmoji TEXT,
            unreadCount INTEGER DEFAULT 0,
            isTyping INTEGER DEFAULT 0,
            memberCount INTEGER DEFAULT 0,
            onlineCount INTEGER DEFAULT 0,
            isOnline INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_messages (
            id TEXT PRIMARY KEY,
            threadId TEXT NOT NULL,
            senderName TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isMine INTEGER DEFAULT 0,
            isRead INTEGER DEFAULT 0,
            attachmentName TEXT,
            attachmentSize TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE saved_items (
            itemId TEXT PRIMARY KEY
          )
        ''');

  }

  Future<void> _seedData(Database db) async {
    for (final item in MockData.feedItems) {
      await db.insert('feed_items', item.toMap());
    }
    for (final club in MockData.clubs) {
      await db.insert('clubs', club.toMap());
    }
    for (final thread in MockData.chatThreads) {
      await db.insert('chat_threads', thread.toMap());
    }
    for (final message in MockData.chatMessages) {
      await db.insert('chat_messages', message.toMap());
    }
  }

  Future<List<FeedItem>> getFeedItems() async {
    final db = await database;
    final rows = await db.query('feed_items', orderBy: 'createdAt DESC');
    return rows.map(FeedItem.fromMap).toList();
  }

  Future<void> saveFeedItems(List<FeedItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'feed_items',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertFeedItem(FeedItem item) async {
    final db = await database;
    await db.insert(
      'feed_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFeedItem(FeedItem item) async {
    final db = await database;
    await db.update(
      'feed_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteFeedItem(String id) async {
    final db = await database;
    await db.delete('feed_items', where: 'id = ?', whereArgs: [id]);
    await db.delete('rsvps', where: 'itemId = ?', whereArgs: [id]);
    await db.delete('saved_items', where: 'itemId = ?', whereArgs: [id]);
  }

  Future<Map<String, RsvpStatus>> getAllRsvps() async {
    final db = await database;
    final rows = await db.query('rsvps');
    final result = <String, RsvpStatus>{};
    for (final row in rows) {
      final itemId = row['itemId'] as String?;
      final statusName = row['status'] as String?;
      if (itemId == null || statusName == null) continue;
      try {
        final status = RsvpStatus.values.byName(statusName);
        if (status != RsvpStatus.none) {
          result[itemId] = status;
        }
      } catch (_) {
        continue;
      }
    }
    return result;
  }

  Future<void> setRsvpStatus(String itemId, RsvpStatus status) async {
    final db = await database;
    if (status == RsvpStatus.none) {
      await db.delete('rsvps', where: 'itemId = ?', whereArgs: [itemId]);
      return;
    }
    await db.insert(
      'rsvps',
      {'itemId': itemId, 'status': status.name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> getSavedItemIds() async {
    final db = await database;
    final rows = await db.query('saved_items');
    return rows.map((r) => r['itemId'] as String).toSet();
  }

  Future<void> toggleSaved(String itemId, bool save) async {
    final db = await database;
    if (save) {
      await db.insert(
        'saved_items',
        {'itemId': itemId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.delete('saved_items', where: 'itemId = ?', whereArgs: [itemId]);
    }
  }

  Future<List<Club>> getClubs() async {
    final db = await database;
    final rows = await db.query('clubs', orderBy: 'memberCount DESC');
    final joined = await getJoinedClubIds();
    return rows
        .map((r) =>
            Club.fromMap(r).copyWith(isJoined: joined.contains(r['id'])))
        .toList();
  }

  Future<void> saveClubs(List<Club> clubs) async {
    final db = await database;
    final batch = db.batch();
    for (final club in clubs) {
      batch.insert(
        'clubs',
        club.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Set<String>> getJoinedClubIds() async {
    final db = await database;
    final rows = await db.query('joined_clubs');
    return rows.map((r) => r['clubId'] as String).toSet();
  }

  Future<void> toggleClubJoin(String clubId, bool join) async {
    final db = await database;
    if (join) {
      await db.insert(
        'joined_clubs',
        {'clubId': clubId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      final rows =
          await db.query('clubs', where: 'id = ?', whereArgs: [clubId]);
      if (rows.isNotEmpty) {
        final count = (rows.first['memberCount'] as int? ?? 0) + 1;
        await db.update(
          'clubs',
          {'memberCount': count},
          where: 'id = ?',
          whereArgs: [clubId],
        );
      }
    } else {
      await db.delete('joined_clubs', where: 'clubId = ?', whereArgs: [clubId]);
      final rows =
          await db.query('clubs', where: 'id = ?', whereArgs: [clubId]);
      if (rows.isNotEmpty) {
        final count = (rows.first['memberCount'] as int? ?? 0) - 1;
        await db.update(
          'clubs',
          {'memberCount': count < 0 ? 0 : count},
          where: 'id = ?',
          whereArgs: [clubId],
        );
      }
    }
  }

  Future<List<ChatThread>> getChatThreads() async {
    final db = await database;
    final rows = await db.query('chat_threads');
    return rows.map(ChatThread.fromMap).toList();
  }

  Future<void> saveChatThreads(List<ChatThread> threads) async {
    final db = await database;
    final batch = db.batch();
    for (final thread in threads) {
      batch.insert(
        'chat_threads',
        thread.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateChatThread(ChatThread thread) async {
    final db = await database;
    await db.update(
      'chat_threads',
      thread.toMap(),
      where: 'id = ?',
      whereArgs: [thread.id],
    );
  }

  Future<List<ChatMessage>> getMessages(String threadId) async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: 'threadId = ?',
      whereArgs: [threadId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(ChatMessage.fromMap).toList();
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert('chat_messages', message.toMap());
  }
}
