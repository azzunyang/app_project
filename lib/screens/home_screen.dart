import 'package:flutter/material.dart';
import 'package:hoseo_notice_app/models/notice.dart';
import 'package:hoseo_notice_app/theme/app_theme.dart';
import 'package:hoseo_notice_app/widgets/notice_banner.dart';
import 'package:hoseo_notice_app/widgets/notice_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NoticeCategory _selectedCategory = NoticeCategory.all;

  List<Notice> get _filteredNotices {
    if (_selectedCategory == NoticeCategory.all) {
      return noticeData;
    }
    return noticeData.where((n) => n.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('호서대학교 공지사항'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner
          const Padding(
            padding: EdgeInsets.all(16),
            child: NoticeBanner(),
          ),
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('전체', NoticeCategory.all),
                _buildCategoryChip('학사', NoticeCategory.academic),
                _buildCategoryChip('장학', NoticeCategory.scholarship),
                _buildCategoryChip('취업', NoticeCategory.job),
                _buildCategoryChip('외부', NoticeCategory.external),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Notice List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredNotices.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return NoticeCard(notice: _filteredNotices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, NoticeCategory category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.mutedColor,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
    );
  }
}
