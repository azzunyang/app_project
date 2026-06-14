import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notice.dart';
import 'api_service.dart';

class ChatbotService {
  static const _baseUrl = 'https://hoseo-backend.onrender.com';

  static Future<({String answer, List<Map<String, dynamic>> references})> chat(
      String question) async {
    // AI 엔드포인트 시도
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'question': question}),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final rawRefs = (data['references'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];
        return (
          answer: data['answer'] as String? ?? '답변을 받지 못했습니다.',
          references: rawRefs,
        );
      }
    } catch (_) {}

    // 학교 홈페이지 기반 fallback (훨씬 더 많은 공지 검색 가능)
    return _websiteFallback(question);
  }

  static Future<({String answer, List<Map<String, dynamic>> references})>
      _websiteFallback(String question) async {
    // 카테고리 키워드 → 카테고리 필터
    const categoryMap = {
      '장학': '장학',
      '장학금': '장학',
      '취업': '취업',
      '인턴': '취업',
      '현장실습': '취업',
      '봉사': '사회봉사',
      '사회봉사': '사회봉사',
      '학사': '학사',
      '수강': '학사',
      '성적': '학사',
      '졸업': '학사',
      '외부': '외부',
      '공모전': '외부',
    };

    try {
      // 1순위: 키워드로 제목 검색 (가장 정확한 결과)
      final keyword = _extractKeyword(question);
      final notices = await ApiService.search(keyword);
      if (notices.isNotEmpty) {
        return _formatNotices(notices, keyword);
      }

      // 2순위: 공백으로 나뉜 단어별 검색 ("국가 장학금" → "국가", "장학금" 각각)
      final words = keyword.split(' ').where((w) => w.length >= 2).toList();
      if (words.length > 1) {
        for (final word in words) {
          final wordResult = await ApiService.search(word);
          if (wordResult.isNotEmpty) {
            return _formatNotices(wordResult, word);
          }
        }
      }

      // 3순위: 2글자씩 쪼개서 병렬 재검색 (붙여쓴 긴 단어 대응)
      final clean = keyword.replaceAll(' ', '');
      if (clean.length >= 4) {
        final parts = <String>[];
        for (int i = 0; i + 2 <= clean.length; i += 2) {
          final part = clean.substring(i, i + 2);
          if (part.trim().isNotEmpty) parts.add(part);
        }
        final futures = parts.map(ApiService.search).toList();
        final results = await Future.wait(futures);
        for (int i = 0; i < results.length; i++) {
          if (results[i].isNotEmpty) {
            return _formatNotices(results[i], parts[i]);
          }
        }
      }

      // 3순위: 카테고리 검색 (키워드로 못 찾을 때만)
      for (final entry in categoryMap.entries) {
        if (question.contains(entry.key)) {
          final catNotices = await ApiService.fetchByCategory(entry.value);
          if (catNotices.isNotEmpty) {
            return _formatNotices(catNotices, entry.key);
          }
        }
      }
    } catch (_) {}

    return (
      answer: '죄송해요, 관련 공지사항을 찾지 못했습니다. 😅\n공지사항 탭에서 직접 검색해 보시거나 학교 포털(https://portal.hoseo.ac.kr)을 이용해 주세요.',
      references: <Map<String, dynamic>>[],
    );
  }

  // 첨부파일만 있는 공지 판별
  static bool _hasRealContent(Notice n) {
    final content = n.content?.trim() ?? '';
    if (content.isEmpty) return false;
    final meaningful = content
        .split('\n')
        .where((line) {
          final l = line.trim();
          return l.isNotEmpty &&
              !l.startsWith('[첨부]') &&
              l != '바로보기' &&
              !RegExp(r'^\[첨부\]').hasMatch(l);
        })
        .join('')
        .trim();
    return meaningful.isNotEmpty;
  }

  static ({String answer, List<Map<String, dynamic>> references})
      _formatNotices(List<Notice> notices, String keyword) {
    // 내용 있는 공지 우선, 없으면 전체에서
    final withContent = notices.where(_hasRealContent).take(3).toList();
    final top = withContent.isNotEmpty
        ? withContent
        : notices.take(3).toList();

    final answer = '\'$keyword\' 관련 공지사항이 있어요. 아래에서 확인해 보세요!';

    return (
      answer: answer,
      references: top.map(_noticeToMap).toList(),
    );
  }

  static Map<String, dynamic> _noticeToMap(Notice n) => {
        'article_id': n.articleId?.toString() ?? n.id,
        'title': n.title,
        'writer': n.department,
        'date': n.date,
        'category': n.category,
        'content': n.content,
        'detail_url': n.detailUrl,
      };

  static String _extractKeyword(String question) {
    // 띄어쓰기 단위로 분리 후 통째로 조사/어미인 단어만 제거
    // ("국가" 안의 "가"처럼 단어 중간 글자는 건드리지 않음)
    const stopWords = {
      '알려줘', '알려주세요', '뭐야', '뭔가요', '어떻게', '어디', '언제',
      '있어', '있나요', '있어요', '해줘', '해주세요',
      '이', '가', '은', '는', '을', '를', '의', '에서', '에', '로', '으로',
      '와', '과', '도', '만', '부터', '까지', '에서는',
      '관련', '관련해서', '대해서', '대해', '어떤', '좀',
      '정보', '안내', '공지', '뭐가', '뭐',
    };
    final words = question
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty && !stopWords.contains(w))
        .toList();
    var keyword = words.join(' ').trim();
    if (keyword.isEmpty) keyword = question.trim();
    if (keyword.length > 20) keyword = keyword.substring(0, 20).trim();
    return keyword;
  }
}
