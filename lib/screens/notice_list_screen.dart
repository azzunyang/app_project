import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../data/sample_data.dart';
import '../services/api_service.dart';
import '../services/liberal_db_service.dart';
import 'notice_detail_screen.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  String _selectedCategory = '전체';
  int _bannerIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;

  List<Notice> _notices = [];
  List<Notice> _liberalNotices = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _categories = ['전체', '학사', '장학', '취업', '외부', '사회봉사', '교양'];

  // 각 카테고리의 최신 공지 1개씩
  List<Notice> get _bannerNotices {
    const cats = ['학사', '장학', '취업', '외부', '사회봉사', '교양'];
    final result = <Notice>[];
    for (final cat in cats) {
      final list = _notices.where((n) => n.category == cat).toList();
      if (list.isNotEmpty) result.add(list.first);
    }
    return result;
  }

  List<Notice> get _filteredNotices {
    if (_selectedCategory == '전체') return _notices;
    if (_selectedCategory == '교양') {
      final normal = _notices.where((n) => n.category == '교양').toList();
      return [..._liberalNotices, ...normal];
    }
    return _notices.where((n) => n.category == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNotices();
    _loadLiberalSubjects();
  }

  Future<void> _loadLiberalSubjects() async {
    try {
      final notices = await LiberalDbService.loadAll();
      if (!mounted) return;
      setState(() => _liberalNotices = notices);
    } catch (_) {}
  }

  Future<void> _loadNotices() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.fetchAll();
      if (!mounted) return;
      allNotices = data;
      setState(() { _notices = data; _isLoading = false; });
      _startAutoSlide();
    } catch (e) {
      if (!mounted) return;
      // API 실패 시 샘플 데이터로 폴백
      allNotices = sampleNotices;
      setState(() { _notices = sampleNotices; _isLoading = false; _error = '서버에 연결할 수 없어 샘플 데이터를 표시합니다.'; });
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final banners = _bannerNotices;
      if (banners.length <= 1) return;
      final next = (_bannerIndex + 1) % banners.length;
      _pageController.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: const Text('호서대학교 공지사항',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: const Color(0xFF1E3A8A),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('공지사항을 불러오는 중...', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadNotices,
      color: const Color(0xFF1E3A8A),
      child: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: const Color(0xFFFEF3C7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 14, color: Color(0xFF92400E)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_error!, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
                ],
              ),
            ),
          _buildBanner(),
          _buildCategoryTabs(),
          Expanded(child: _buildNoticeList()),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    final banners = _bannerNotices;
    if (banners.isEmpty) return const SizedBox.shrink();
    return Container(
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              itemBuilder: (_, i) => _buildBannerCard(banners[i]),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _bannerIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _bannerIndex ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerCard(Notice notice) {
    final color = Notice.categoryColor(notice.category);
    return GestureDetector(
      onTap: () => _openDetail(notice),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: Text(notice.category,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Text(notice.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 4),
            Text(notice.department,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFD1D5DB),
                  ),
                ),
                child: Text(cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNoticeList() {
    final notices = _filteredNotices;
    if (notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text('$_selectedCategory 공지사항이 없습니다.',
                style: const TextStyle(color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: notices.length,
      itemBuilder: (_, i) => _buildNoticeItem(notices[i]),
    );
  }

  Widget _buildNoticeItem(Notice notice) {
    final color = Notice.categoryColor(notice.category);
    return GestureDetector(
      onTap: () => _openDetail(notice),
      child: Container(
        color: notice.isPinned ? const Color(0xFFF0FDF4) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (notice.isPinned) ...[
                        const Icon(Icons.push_pin, size: 13, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(notice.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827), height: 1.4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
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
                  color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(notice.category,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Notice notice) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice)));
  }
}
