import 'package:flutter/material.dart';
import 'package:hoseo_notice_app/models/notice.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;

  const NoticeCard({
    Key? key,
    required this.notice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to detail screen
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${notice.department} ${notice.date}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9BA1A6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildTag(),
          ],
        ),
      ),
    );
  }

  Widget _buildTag() {
    if (notice.isImportant) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '중요',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFDC2626),
          ),
        ),
      );
    }

    final colors = categoryColors[notice.category]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(int.parse('0xFF${colors['bg']!.replaceFirst('#', '')}')),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        colors['label']!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(int.parse('0xFF${colors['text']!.replaceFirst('#', '')}')),
        ),
      ),
    );
  }
}
