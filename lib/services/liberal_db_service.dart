import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/notice.dart';

class LiberalDbService {
  static Future<Notice> loadAreaAsNotice(int area) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, 'liberal_area$area.db');

    // 항상 assets에서 최신 파일로 덮어씀 (버전 불일치 방지)
    final data = await rootBundle.load('assets/db/liberal_area$area.db');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);

    final db = await openDatabase(dbPath, readOnly: true);
    final rows = await db.query('liberal_subjects');
    await db.close();

    final buffer = StringBuffer();
    for (final row in rows) {
      final name    = (row['교과목명'] as String? ?? '').trim();
      final code    = (row['학수번호'] as String? ?? '').trim();
      final section = (row['분반']    as String? ?? '').trim();
      final remarks = (row['비고']    as String? ?? '').trim();
      buffer.write('• $name  ($code-$section)');
      if (remarks.isNotEmpty) buffer.write('  [$remarks]');
      buffer.writeln();
    }

    return Notice(
      id:         'liberal_area_$area',
      title:      '$area교양 영역',
      department: '교양대학',
      date:       '',
      category:   '교양',
      isPinned:   true,
      content:    buffer.toString().trimRight(),
    );
  }

  static Future<List<Notice>> loadAll() async {
    final results = await Future.wait([
      loadAreaAsNotice(1),
      loadAreaAsNotice(2),
      loadAreaAsNotice(3),
      loadAreaAsNotice(4),
    ]);
    return results;
  }
}
