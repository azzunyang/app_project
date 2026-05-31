import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  final Map<String, bool> _categorySubscriptions = {
    '학사': true,
    '장학': true,
    '취업': false,
    '외부': false,
    '사회봉사': false,
    '영역별교양': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool('push_enabled') ?? true;
      for (final cat in _categorySubscriptions.keys) {
        _categorySubscriptions[cat] = prefs.getBool('cat_$cat') ?? _categorySubscriptions[cat]!;
      }
    });
  }

  Future<void> _savePush(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_enabled', val);
  }

  Future<void> _saveCat(String cat, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cat_$cat', val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 24, bottom: 40),
        children: [
          _sectionLabel('알림 설정'),
          _settingsCard([
            _switchTile(
              title: '푸시 알림',
              subtitle: '새 공지사항 알림을 받습니다',
              value: _pushEnabled,
              onChanged: (v) {
                setState(() => _pushEnabled = v);
                _savePush(v);
              },
            ),
          ]),
          const SizedBox(height: 24),
          _sectionLabel('카테고리 구독'),
          _settingsCard(
            _categorySubscriptions.keys.map((cat) {
              final isLast = cat == _categorySubscriptions.keys.last;
              return _switchTile(
                title: cat,
                value: _categorySubscriptions[cat]!,
                showDivider: !isLast,
                onChanged: (v) {
                  setState(() => _categorySubscriptions[cat] = v);
                  _saveCat(cat, v);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _sectionLabel('앱 정보'),
          _settingsCard([
            _infoTile('앱 버전', '1.0.0'),
            _infoTile('개발', '호서대학교', showDivider: false),
          ]),
          const SizedBox(height: 24),
          _sectionLabel('기타'),
          _settingsCard([
            _actionTile(
              icon: Icons.notifications_off_outlined,
              title: '알림 초기화',
              onTap: () => _showDialog('알림 설정을 초기화하겠습니까?', () {
                setState(() => _pushEnabled = true);
                _savePush(true);
              }),
            ),
            _actionTile(
              icon: Icons.delete_outline,
              title: '즐겨찾기 전체 삭제',
              color: const Color(0xFFEF4444),
              showDivider: false,
              onTap: () => _showDialog('즐겨찾기를 전체 삭제하겠습니까?', () {}),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: const Color(0xFF1E3A8A),
                activeTrackColor: const Color(0xFF93C5FD),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  Widget _infoTile(String title, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF374151),
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider ? BorderRadius.zero : const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  void _showDialog(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('확인'),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('확인', style: TextStyle(color: Color(0xFF1E3A8A))),
          ),
        ],
      ),
    );
  }
}
