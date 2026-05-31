import 'package:shared_preferences/shared_preferences.dart';
import '../models/notice.dart';

class FavoritesService {
  static const _key = 'favorite_ids';

  static Future<Set<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> add(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_key) ?? []).toSet()..add(id);
    await prefs.setStringList(_key, ids.toList());
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_key) ?? []).toSet()..remove(id);
    await prefs.setStringList(_key, ids.toList());
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> applyTo(List<Notice> notices) async {
    final ids = await loadIds();
    for (final n in notices) {
      n.isFavorite = ids.contains(n.id);
    }
  }
}
