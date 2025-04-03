import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  static const String tableName = 'notifications';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'health_mate_notifications.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $tableName(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            type INTEGER NOT NULL,
            timestamp INTEGER NOT NULL,
            payload TEXT,
            isRead INTEGER NOT NULL
          )
          ''',
        );
      },
    );
  }

  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert(
      tableName,
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      tableName,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllAsRead() async {
    final db = await database;
    await db.update(
      tableName,
      {'isRead': 1},
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> deleteAllNotifications() async {
    final db = await database;
    await db.delete(tableName);
  }

  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE isRead = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}