import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notice.dart';
import '../services/api_service.dart';
import 'notice_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<Notice> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() { _results = []; _lastQuery = ''; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    setState(() { _isSearching = true; _lastQuery = query; });
    try {
      final results = await ApiService.search(query);
      if (!mounted) return;
      setState(() { _results = results; _isSearching = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _results = []; _isSearching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '공지사항 검색...',
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: _onChanged,
            onSubmitted: (q) { if (q.trim().isNotEmpty) _search(q.trim()); },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.text.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search, size: 64, color: Color(0xFFD1D5DB)),
          SizedBox(height: 16),
          Text('검색어를 입력하세요', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15)),
          SizedBox(height: 8),
          Text('제목, 담당 부서로 검색할 수 있어요', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13)),
        ]),
      );
    }
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off, size: 64, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text('"$_lastQuery" 검색 결과가 없습니다.',
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _results.length,
      itemBuilder: (_, i) => _buildItem(_results[i]),
    );
  }

  Widget _buildItem(Notice notice) {
    final color = Notice.categoryColor(notice.category);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice))),
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _highlightText(notice.title, _lastQuery),
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
              ]),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(notice.category,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)));
    }
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx == -1) {
      return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(text: text.substring(idx, idx + query.length),
              style: const TextStyle(color: Color(0xFF1E3A8A), backgroundColor: Color(0xFFDBEAFE))),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
