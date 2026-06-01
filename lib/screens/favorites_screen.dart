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
          backgroundColor: const Color(0xFFF0F4F8),
          body: Column(
            children: [
              _buildPageHeader(context),
              Expanded(
                child: favorites.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        itemCount: favorites.length,
                        itemBuilder: (_, i) => _buildItem(context, favorites[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('내가 별표한 공지',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text('즐겨찾기',
                      style: TextStyle(color: Color(0xFF111827), fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/settings'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFF0F4F8), shape: BoxShape.circle),
                  child: const Icon(Icons.settings_outlined, color: Color(0xFF6B7280), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notice.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827), height: 1.4)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                        child: Text(notice.department,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ),
                      if (notice.date.isNotEmpty) ...[
                        const Text(' · ', style: TextStyle(fontSize: 12, color: Color(0xFFD1D5DB))),
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
              child: Text(notice.category,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text('즐겨찾기한 공지사항이 없습니다.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('공지사항 상세에서 별표를 눌러 추가하세요.',
                style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
