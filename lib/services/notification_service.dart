import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  // 백그라운드 또는 포그라운드에서 새 공지 확인 후 알림 발송
  static Future<void> checkAndNotify() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('push_enabled') ?? true)) return;

    final subscribedCats = {
      '학사': prefs.getBool('cat_학사') ?? true,
      '장학': prefs.getBool('cat_장학') ?? true,
      '취업': prefs.getBool('cat_취업') ?? false,
      '외부': prefs.getBool('cat_외부') ?? false,
      '사회봉사': prefs.getBool('cat_사회봉사') ?? false,
      '교양': prefs.getBool('cat_영역별교양') ?? false,
    }.entries.where((e) => e.value).map((e) => e.key).toSet();

    if (subscribedCats.isEmpty) return;

    final lastId = prefs.getString('last_seen_notice_id');
    final notices = await ApiService.fetchAll(pages: 1);
    if (notices.isEmpty) return;

    // 최신 ID 저장
    await prefs.setString('last_seen_notice_id', notices.first.id);

    // 첫 실행이면 알림 없이 기준점만 저장
    if (lastId == null) return;

    final newNotices = <String>[];
    String? firstCat;
    for (final n in notices) {
      if (n.id == lastId) break;
      if (subscribedCats.contains(n.category)) {
        newNotices.add(n.title);
        firstCat ??= n.category;
      }
    }

    if (newNotices.isEmpty) return;

    final title = newNotices.length == 1
        ? '[$firstCat] 새 공지사항'
        : '호서대학교 새 공지사항 ${newNotices.length}건';
    final body = newNotices.length == 1
        ? newNotices.first
        : newNotices.take(3).join('\n');

    await _show(title: title, body: body);
  }

  // 앱을 열었을 때 last_seen_notice_id 갱신 (이미 본 공지는 알림 안 뜨게)
  static Future<void> markSeen(String latestId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_seen_notice_id', latestId);
  }

  static Future<void> _show({required String title, required String body}) async {
    const android = AndroidNotificationDetails(
      'hoseo_notice',
      '호서대 공지사항',
      channelDescription: '새 공지사항 알림',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.show(
      0, title, body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }
}
