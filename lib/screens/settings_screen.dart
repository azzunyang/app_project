import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _academicEnabled = true;
  bool _scholarshipEnabled = true;
  bool _jobEnabled = false;
  bool _externalEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 알림 설정
          _buildSectionHeader('알림 설정'),
          _buildSettingCard(
            title: '푸시 알림',
            subtitle: '새 공지사항 알림을 받습니다',
            value: _pushEnabled,
            onChanged: (value) {
              setState(() {
                _pushEnabled = value;
              });
            },
          ),
          // 카테고리 구독
          _buildSectionHeader('카테고리 구독'),
          _buildSettingCard(
            title: '학사',
            value: _academicEnabled,
            onChanged: (value) {
              setState(() {
                _academicEnabled = value;
              });
            },
          ),
          _buildSettingCard(
            title: '장학',
            value: _scholarshipEnabled,
            onChanged: (value) {
              setState(() {
                _scholarshipEnabled = value;
              });
            },
          ),
          _buildSettingCard(
            title: '취업',
            value: _jobEnabled,
            onChanged: (value) {
              setState(() {
                _jobEnabled = value;
              });
            },
          ),
          _buildSettingCard(
            title: '외부',
            value: _externalEnabled,
            onChanged: (value) {
              setState(() {
                _externalEnabled = value;
              });
            },
          ),
          // 앱 정보
          _buildSectionHeader('앱 정보'),
          _buildInfoCard('앱 버전', '1.0.0'),
          _buildInfoCard('개발', '호서대학교'),
          _buildInfoCard('개인정보 처리방침', '보기 →'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9BA1A6),
                      ),
                    ),
                  ),
              ],
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1E3A7B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
