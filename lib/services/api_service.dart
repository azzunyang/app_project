import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notice.dart';

class ApiService {
  static const _baseUrl = 'https://www.hoseo.ac.kr';
  static const _listAction = 'MAPP_1708240139';
  static const _categoryCode = 'CTG_17082400011';
  static const _volunteerCategoryCode = 'CTG_17082400014';
  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
        'Mobile/15E148 Safari/604.1',
  };

  static Future<List<Notice>> fetchAll({int pages = 4}) async {
    // 일반 공지 4페이지 + 사회봉사 전용 게시판 2페이지 병렬 실행
    final futures = [
      ...List.generate(pages, (i) => _fetchPage(i + 1, _categoryCode)),
      _fetchPage(1, _volunteerCategoryCode),
      _fetchPage(2, _volunteerCategoryCode),
    ];
    final results = await Future.wait(futures);
    final all = results.expand((list) => list).toList();
    // 날짜 내림차순 정렬 후 article_id 기준 중복 제거
    all.sort((a, b) => b.date.compareTo(a.date));
    final seen = <String>{};
    return all.where((n) => seen.add(n.id)).toList();
  }

  static Future<List<Notice>> _fetchPage(int page, String categoryCode) async {
    final url = Uri.parse(
      '$_baseUrl/Home/BBSList.mbz'
      '?action=$_listAction'
      '&schCategorycode=$categoryCode'
      '&pageIndex=$page',
    );
    try {
      final res = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];
      final html = utf8.decode(res.bodyBytes, allowMalformed: true);
      return _parseList(html, categoryCode: categoryCode);
    } catch (_) {
      return [];
    }
  }

  static List<Notice> _parseList(String html, {String categoryCode = _categoryCode}) {
    final notices = <Notice>[];
    final isVolunteer = categoryCode == _volunteerCategoryCode;
    // <tr> 블록 단위로 분리
    final blocks = html.split(RegExp(r'<tr[\s>]'));
    for (final block in blocks) {
      final idxM    = RegExp(r"fn_viewData\('(\d+)'\)").firstMatch(block);
      final titleM  = RegExp(r"fn_viewData\('\d+'\)[^>]*>\s*([^\n<]{5,120})").firstMatch(block);
      final deptM   = RegExp(r'<td>([^<]{2,30})</td>').firstMatch(block);
      final dateM   = RegExp(r'<td class="txt-center pc_view">([\d-]+)</td>').firstMatch(block);
      if (idxM == null || dateM == null) continue;

      final articleId = idxM.group(1)!;
      final title     = _clean(titleM?.group(1) ?? '');
      final dept      = _clean(deptM?.group(1) ?? '');
      final date      = dateM.group(1)!;
      final detailUrl = '$_baseUrl/Home/BBSView.mbz'
          '?action=$_listAction'
          '&schIdx=$articleId'
          '&schCategorycode=$categoryCode'
          '&schKeytype=subject&schKeyword=&pageIndex=1';

      if (title.isEmpty) continue;
      notices.add(Notice(
        id:         articleId,
        articleId:  int.tryParse(articleId),
        title:      title,
        department: dept,
        date:       date,
        category:   isVolunteer ? '사회봉사' : Notice.inferCategory(dept, title),
        detailUrl:  detailUrl,
      ));
    }
    return notices;
  }

  static String _clean(String s) =>
      s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static Future<List<Notice>> fetchByCategory(String category) async {
    final all = await fetchAll();
    return all.where((n) => n.category == category).toList();
  }

  static Future<List<Notice>> search(String keyword) async {
    final url = Uri.parse(
      '$_baseUrl/Home/BBSList.mbz'
      '?action=$_listAction'
      '&schCategorycode=$_categoryCode'
      '&schKeytype=subject'
      '&schKeyword=${Uri.encodeComponent(keyword)}'
      '&pageIndex=1',
    );
    try {
      final res = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];
      return _parseList(utf8.decode(res.bodyBytes, allowMalformed: true));
    } catch (_) {
      return [];
    }
  }

  static Future<String?> fetchDetailContent(String detailUrl) async {
    try {
      final res = await http
          .get(Uri.parse(detailUrl), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final html = utf8.decode(res.bodyBytes, allowMalformed: true);
      return _parseDetailContent(html);
    } catch (_) {
      return null;
    }
  }

  static String? _parseDetailContent(String html) {
    final m = RegExp(
      r'<div[^>]*class="[^"]*board[^"]*view[^"]*content[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(html);
    if (m == null) return null;
    final text = m.group(1)!
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return text.isEmpty ? null : text;
  }
}
