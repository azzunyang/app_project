import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../data/sample_data.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../services/liberal_db_service.dart';
import '../services/notification_service.dart';
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

  final List<String> _categories = ['전체', '학사', '장학', '취업', '외부', '사회봉사', '교양', '기타'];

  List<Notice> get _bannerNotices {
    const cats = ['학사', '장학', '취업', '외부', '사회봉사', '교양', '기타'];
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
    NotificationService.requestPermission();
  }

  Future<void> _loadLiberalSubjects() async {
    try {
      final notices = await LiberalDbService.loadAll();
      if (!mounted) return;
      setState(() => _liberalNotices = notices);
    } catch (e) {
      debugPrint('liberal DB load error: $e');
    }
  }

  Future<void> _loadNotices() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.fetchAll();
      await FavoritesService.applyTo(data);
      if (!mounted) return;
      allNotices = data;
      NotificationService.checkAndNotify().then((_) {
        if (data.isNotEmpty) NotificationService.markSeen(data.first.id);
      });
      setState(() { _notices = data; _isLoading = false; });
      _startAutoSlide();
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _error = '공지사항을 불러오지 못했습니다. 네트워크를 확인해 주세요.'; });
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final banners = _bannerNotices;
      if (banners.length <= 1) return;
      if (!_pageController.hasClients) return;
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
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          _buildPageHeader(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F))))
          else if (_error != null && _notices.isEmpty)
            Expanded(child: _buildErrorState())
          else ...[
            if (_error != null) _buildErrorBanner(),
            _buildBanner(),
            _buildCategoryTabs(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadNotices,
                color: const Color(0xFF1E3A5F),
                child: _buildNoticeList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
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
                  Text('오늘의 학교 소식',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text('공지사항',
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(color: Color(0xFFF0F2F7), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: Color(0xFFD1D5DB)),
            ),
            const SizedBox(height: 20),
            const Text('공지사항을 불러오지 못했습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            const SizedBox(height: 8),
            const Text('네트워크 연결을 확인하고 다시 시도해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), height: 1.5)),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _loadNotices,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('다시 시도', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
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
    );
  }

  Widget _buildBanner() {
    final banners = _bannerNotices;
    if (banners.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                padEnds: false,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _bannerIndex = i),
                itemBuilder: (_, i) => _buildBannerCard(banners[i]),
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _bannerIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _bannerIndex ? const Color(0xFF1E3A5F) : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ],
        ],
      ),
    );
  }

  static List<Color> _bannerGradient(String category) {
    switch (category) {
      case '학사': return [const Color(0xFF1D4ED8), const Color(0xFF60A5FA)];
      case '장학': return [const Color(0xFF065F46), const Color(0xFF10B981)];
      case '취업': return [const Color(0xFF7C3AED), const Color(0xFFA78BFA)];
      case '외부': return [const Color(0xFF92400E), const Color(0xFFF59E0B)];
      case '사회봉사': return [const Color(0xFF9D174D), const Color(0xFFF472B6)];
      case '교양': return [const Color(0xFF0E7490), const Color(0xFF22D3EE)];
      case '기타': return [const Color(0xFF4338CA), const Color(0xFF818CF8)];
      default: return [const Color(0xFF1E3A5F), const Color(0xFF4A90D9)];
    }
  }

  static IconData _bannerIcon(String category) {
    switch (category) {
      case '학사': return Icons.school_outlined;
      case '장학': return Icons.attach_money_rounded;
      case '취업': return Icons.work_outline_rounded;
      case '외부': return Icons.public_outlined;
      case '사회봉사': return Icons.volunteer_activism_outlined;
      case '교양': return Icons.menu_book_outlined;
      case '기타': return Icons.info_outline_rounded;
      default: return Icons.campaign_outlined;
    }
  }

  Widget _buildBannerCard(Notice notice) {
    final gradients = _bannerGradient(notice.category);
    final icon = _bannerIcon(notice.category);
    return GestureDetector(
      onTap: () => _openDetail(notice),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon, size: 80, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(notice.category,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('최신 공지',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notice.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, height: 1.4),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 12, color: Colors.white60),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(notice.department,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white60),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
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
                  color: isSelected ? const Color(0xFF1E3A5F) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFD1D5DB),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: notices.length,
      itemBuilder: (_, i) => _buildNoticeItem(notices[i]),
    );
  }

  Widget _buildNoticeItem(Notice notice) {
    final color = Notice.categoryColor(notice.category);
    final dotColor = notice.isPinned ? const Color(0xFF059669) : color;
    return GestureDetector(
      onTap: () => _openDetail(notice),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
            ),
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
