import 'package:sqflite/sqflite.dart';

import '../../models/exhibit.dart';
import 'database_helper.dart';

class LocalDataSource {
  LocalDataSource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _dbHelper;

  Future<void> ensureSeedData() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM exhibits');
    final count = Sqflite.firstIntValue(result) ?? 0;
    if (count == 0) {
      await db.insert('exhibits', _sampleExhibit('Sacred Ashes', 'An artifact representing the lineage of sacred fires.'));
      await db.insert('exhibits', _sampleExhibit('Temple Bells', 'Traditional bells used during evening aarti rituals.'));
      await db.insert('exhibits', _sampleExhibit('Ancient Manuscript', 'Palm-leaf manuscript describing spiritual practices.'));
    }
  }

  Map<String, Object?> _sampleExhibit(String title, String description) {
    return Exhibit(
      title: title,
      description: description,
      createdAt: DateTime.now().toIso8601String(),
    ).toMap();
  }

  Future<List<Exhibit>> fetchExhibits() async {
    final db = await _dbHelper.database;
    final maps = await db.query('exhibits', orderBy: 'createdAt DESC');
    return maps.map(Exhibit.fromMap).toList();
  }

  Future<int> insertExhibit(Exhibit exhibit) async {
    final db = await _dbHelper.database;
    return db.insert('exhibits', exhibit.toMap());
  }

  Future<int> updateExhibit(Exhibit exhibit) async {
    final db = await _dbHelper.database;
    return db.update(
      'exhibits',
      exhibit.toMap(),
      where: 'id = ?',
      whereArgs: [exhibit.id],
    );
  }

  Future<int> deleteExhibit(int id) async {
    final db = await _dbHelper.database;
    return db.delete('exhibits', where: 'id = ?', whereArgs: [id]);
  }
}
