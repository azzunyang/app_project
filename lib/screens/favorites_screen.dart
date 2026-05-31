import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../data/sample_data.dart';
import 'notice_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: favoritesNotifier,
      builder: (context, v, w) {
        final favorites = allNotices.where((n) => n.isFavorite).toList();
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F1E3D),
            elevation: 0,
            title: const Text('즐겨찾기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.of(context).pushNamed('/settings'),
              ),
            ],
          ),
          body: favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_border, size: 64, color: Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text('즐겨찾기한 공지사항이 없습니다.', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15)),
                      SizedBox(height: 8),
                      Text('공지사항 상세에서 별표를 눌러 추가하세요.', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: favorites.length,
                  itemBuilder: (_, i) => _buildItem(context, favorites[i]),
                ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, Notice notice) {
    final color = Notice.categoryColor(notice.category);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice)),
      ),
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notice.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 12, color: Color(0xFFB0B8C1)),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(notice.department,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ),
                      if (notice.date.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFFB0B8C1)),
                        const SizedBox(width: 3),
                        Text(notice.date,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(notice.category, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
