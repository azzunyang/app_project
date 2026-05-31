import 'package:flutter/material.dart';

class Notice {
  final String id;
  final int? articleId;
  final String title;
  final String department;
  final String date;
  final String category;
  final bool isFeatured;
  final String? dday;

  final String? content;
  final String? detailUrl;
  final bool isPinned;
  bool isFavorite;

  Notice({
    required this.id,
    this.articleId,
    required this.title,
    required this.department,
    required this.date,
    required this.category,
    this.isFeatured = false,
    this.isPinned = false,
    this.dday,
    this.content,
    this.detailUrl,
    this.isFavorite = false,
  });

  factory Notice.fromApi(Map<String, dynamic> json) {
    final writer = (json['writer'] as String? ?? '').trim();
    final title  = (json['title']  as String? ?? '').trim();
    return Notice(
      id:         json['article_id'].toString(),
      articleId:  json['article_id'] as int?,
      title:      title,
      department: writer,
      date:       (json['date'] as String? ?? '').trim(),
      category:   inferCategory(writer, title),
      content:    json['content'] as String?,
      detailUrl:  json['detail_url'] as String?,
    );
  }

  static String inferCategory(String writer, String title) {
    final w = writer;
    final t = title;
    if (w.contains('장학') || t.contains('장학')) { return '장학'; }
    if (w.contains('취업') || w.contains('현장실습') ||
        t.contains('취업') || t.contains('현장실습') || t.contains('인턴')) { return '취업'; }
    if (w.contains('봉사') || w.contains('Caritas') ||
        t.contains('봉사')) { return '사회봉사'; }
    if (w.contains('교양') || w.contains('에듀테크') ||
        t.contains('교양')) { return '교양'; }
    if (w.contains('학사') || w.contains('교무') || w.contains('학술') ||
        w.contains('에듀')) { return '학사'; }
    return '외부';
  }

  static Color categoryColor(String category) {
    switch (category) {
      case '학사':
        return const Color(0xFF2563EB);
      case '장학':
        return const Color(0xFF9333EA);
      case '취업':
        return const Color(0xFF0D9488);
      case '외부':
        return const Color(0xFFEA580C);
      case '사회봉사':
        return const Color(0xFFE11D48);
      case '교양':
        return const Color(0xFF0891B2);
      case '1교양 영역':
        return const Color(0xFF059669);
      case '2교양 영역':
        return const Color(0xFFD97706);
      case '3교양 영역':
        return const Color(0xFF7C3AED);
      case '4교양 영역':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
