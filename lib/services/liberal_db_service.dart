import '../models/notice.dart';
import '../data/liberal_data.dart';

class LiberalDbService {
  static Notice _buildNotice(int area, List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      final name    = row[0];
      final code    = row[1];
      final section = row[2];
      final remarks = row[3];
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
    return [
      _buildNotice(1, liberalArea1),
      _buildNotice(2, liberalArea2),
      _buildNotice(3, liberalArea3),
      _buildNotice(4, liberalArea4),
    ];
  }
}
