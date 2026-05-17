import 'package:flutter/material.dart';
import 'package:hoseo_notice_app/models/notice.dart';
import 'package:hoseo_notice_app/theme/app_theme.dart';

class NoticeBanner extends StatefulWidget {
  const NoticeBanner({Key? key}) : super(key: key);

  @override
  State<NoticeBanner> createState() => _NoticeBannerState();
}

class _NoticeBannerState extends State<NoticeBanner> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  //배너 슬라이드 부분
  //필요시 코드 추가 예정
  void _startAutoSlide() {

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerColors = [
      const Color(0xFF1E3A7B),  // 파란색
      const Color(0xFF1E3A7B),
      const Color(0xFF1E3A7B),
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index % bannerNotices.length;
              });
              _startAutoSlide();
            },
            itemBuilder: (context, index) {
              final notice = bannerNotices[index % bannerNotices.length];
              final bgColor = bannerColors[index % bannerColors.length];
              return _buildBannerSlide(notice, bgColor);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerNotices.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: index == _currentPage ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSlide(Notice notice, Color bgColor) {
    final colors = categoryColors[notice.category]!;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color(int.parse('0xFF${colors['bg']!.replaceFirst('#', '')}')),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              notice.category.toString().split('.').last == 'academic'
                  ? '학사'
                  : notice.category.toString().split('.').last == 'scholarship'
                      ? '장학'
                      : notice.category.toString().split('.').last == 'job'
                          ? '취업'
                          : '외부',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(int.parse('0xFF${colors['text']!.replaceFirst('#', '')}')),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            notice.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          if (notice.dDay != null)
            Text(
              notice.dDay!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.75),
              ),
            ),
        ],
      ),
    );
  }
}
