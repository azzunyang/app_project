import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/notice.dart';
import '../data/sample_data.dart';

class NoticeDetailScreen extends StatefulWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _Attachment {
  final String name;
  final String url;
  const _Attachment({required this.name, required this.url});
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  late bool _isFavorite;
  List<String> _imageUrls = [];
  List<_Attachment> _attachments = [];
  bool _loadingImages = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.notice.isFavorite;
    if (widget.notice.detailUrl?.isNotEmpty == true) {
      _fetchImages();
    }
  }

  Future<void> _fetchImages() async {
    setState(() => _loadingImages = true);
    try {
      final res = await http.get(
        Uri.parse(widget.notice.detailUrl!),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final html = utf8.decode(res.bodyBytes, allowMalformed: true);

        // 이미지 추출
        final imagePattern = RegExp(r'/ThumbnailPrint\.do\?[^<\s"]+');
        final urls = imagePattern
            .allMatches(html)
            .map((m) =>
                'https://www.hoseo.ac.kr${m.group(0)!.replaceAll('&amp;', '&')}')
            .toSet()
            .toList();

        // 첨부파일 추출: href="/File/Download.do?..."
        final attachPattern =
            RegExp(r'href="(/File/Download\.do\?[^"]+)"');
        final attachments = <_Attachment>[];
        for (final m in attachPattern.allMatches(html)) {
          final path = m.group(1)!.replaceAll('&amp;', '&');
          final uri = Uri.parse('https://www.hoseo.ac.kr$path');
          final rawName = uri.queryParameters['realname'] ?? '';
          final name = rawName.replaceFirst(RegExp(r'^\[첨부\]'), '').trim();
          if (name.isNotEmpty) {
            attachments.add(_Attachment(
              name: name,
              url: 'https://www.hoseo.ac.kr$path',
            ));
          }
        }

        setState(() {
          _imageUrls = urls;
          _attachments = attachments;
          _loadingImages = false;
        });
      } else {
        setState(() => _loadingImages = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingImages = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Notice.categoryColor(widget.notice.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('공지사항', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? const Color(0xFFF59E0B) : Colors.white,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              toggleFavorite(widget.notice);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(color),
            if (_loadingImages) _buildImageLoading(),
            if (_imageUrls.isNotEmpty) _buildImages(),
            _buildContent(),
            if (_attachments.isNotEmpty) _buildAttachments(),
            if (widget.notice.detailUrl?.isNotEmpty == true) _buildOriginalButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.notice.category,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.notice.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(widget.notice.department,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (widget.notice.date.isNotEmpty) ...[
                const SizedBox(width: 20),
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white54, size: 14),
                const SizedBox(width: 4),
                Text(widget.notice.date,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF2E7D32)),
            ),
            SizedBox(width: 10),
            Text('이미지 불러오는 중...',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _buildImages() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.image_outlined, size: 16, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Text('첨부 이미지',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          ..._imageUrls.map((url) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ImageCard(
                  url: url,
                  onTap: () => _openFullScreenImage(url),
                ),
              )),
        ],
      ),
    );
  }

  void _openFullScreenImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImagePage(url: url),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildContent() {
    final content = widget.notice.content;
    final hasContent = content != null && content.trim().isNotEmpty;

    if (!hasContent) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Color(0xFF9CA3AF)),
            SizedBox(width: 8),
            Text('상세 내용은 원문을 확인해주세요.',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    if (widget.notice.isPinned) {
      return _buildSubjectList(content);
    }

    return _buildTextContent(content);
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2)),
      ],
    );
  }

  // 교양 영역 공지 — 과목 목록 카드 형태
  Widget _buildSubjectList(String content) {
    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                const Text('과목 목록',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${lines.length}개',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lines.length,
            separatorBuilder: (_, sep) => const Divider(height: 1, color: Color(0xFFF9FAFB), indent: 16),
            itemBuilder: (_, i) => _buildSubjectItem(lines[i], i),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(String line, int index) {
    // 파싱: • 교과목명  (학수번호-분반)  [비고]
    String text = line.replaceFirst(RegExp(r'^[•\-]\s*'), '').trim();
    final codeMatch = RegExp(r'\(([^)]+)\)').firstMatch(text);
    final remarksMatch = RegExp(r'\[([^\]]*)\]').firstMatch(text);

    String name = text;
    String? code;
    String? remarks;

    if (codeMatch != null) {
      name = text.substring(0, codeMatch.start).trim();
      code = codeMatch.group(1);
    }
    if (remarksMatch != null) {
      remarks = remarksMatch.group(1)?.trim();
      if (remarks?.isEmpty == true) remarks = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.4)),
                if (remarks != null) ...[
                  const SizedBox(height: 4),
                  Text(remarks,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          height: 1.4)),
                ],
              ],
            ),
          ),
          if (code != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(code,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }

  // 일반 공지 — 단락/글머리 구분 렌더링
  Widget _buildTextContent(String content) {
    final paragraphs = content
        .split(RegExp(r'\n{2,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.article_outlined, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Text('공지 내용',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          ...paragraphs.asMap().entries.map((e) {
            final i = e.key;
            final para = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: i < paragraphs.length - 1 ? 14 : 0),
              child: _buildParagraph(para),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParagraph(String para) {
    final lines = para.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.length == 1) {
      return _buildLine(lines.first);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.asMap().entries.map((e) => Padding(
        padding: EdgeInsets.only(bottom: e.key < lines.length - 1 ? 6 : 0),
        child: _buildLine(e.value),
      )).toList(),
    );
  }

  Widget _buildLine(String line) {
    final isBullet = line.startsWith('•') || line.startsWith('-') || line.startsWith('·');
    if (isBullet) {
      final text = line.replaceFirst(RegExp(r'^[•\-·]\s*'), '');
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: CircleAvatar(radius: 2.5, backgroundColor: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(text,
                style: const TextStyle(
                    fontSize: 15, height: 1.75, color: Color(0xFF374151))),
          ),
        ],
      );
    }
    // 제목처럼 보이는 줄 (짧고 콜론으로 끝나거나 굵게 처리할 부분)
    final isHeading = line.length < 30 && (line.endsWith(':') || line.endsWith('：') || RegExp(r'^\d+\.').hasMatch(line));
    if (isHeading) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SelectableText(line,
            style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700)),
      );
    }
    return SelectableText(line,
        style: const TextStyle(
            fontSize: 15, height: 1.75, color: Color(0xFF374151)));
  }

  Widget _buildAttachments() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Text('첨부파일',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 8),
          ..._attachments.map((a) => _buildAttachmentItem(a)),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(_Attachment attachment) {
    final ext = attachment.name.contains('.')
        ? attachment.name.split('.').last.toLowerCase()
        : '';
    final icon = _fileIcon(ext);
    final iconColor = _fileColor(ext);
    return GestureDetector(
      onTap: () => _openUrl(attachment.url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                attachment.name,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.download_outlined, size: 18, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(String ext) {
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf_outlined;
      case 'hwp':
      case 'hwpx':
      case 'doc':
      case 'docx': return Icons.description_outlined;
      case 'xls':
      case 'xlsx': return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx': return Icons.slideshow_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif': return Icons.image_outlined;
      case 'zip':
      case 'rar': return Icons.folder_zip_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  Color _fileColor(String ext) {
    switch (ext) {
      case 'pdf': return const Color(0xFFDC2626);
      case 'hwp':
      case 'hwpx':
      case 'doc':
      case 'docx': return const Color(0xFF2E7D32);
      case 'xls':
      case 'xlsx': return const Color(0xFF16A34A);
      case 'ppt':
      case 'pptx': return const Color(0xFFEA580C);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif': return const Color(0xFF7C3AED);
      case 'zip':
      case 'rar': return const Color(0xFFCA8A04);
      default: return const Color(0xFF6B7280);
    }
  }

  Widget _buildOriginalButton() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: () => _openUrl(widget.notice.detailUrl!),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_browser_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('원문 보기',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 이미지 카드: 긴 이미지는 접힌 상태로 표시, 펼치기/접기 버튼 제공 ───

class _ImageCard extends StatefulWidget {
  final String url;
  final VoidCallback onTap;
  const _ImageCard({required this.url, required this.onTap});

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  bool _expanded = false;
  double? _renderedHeight;

  static const double _threshold = 400;

  bool get _isTall => _renderedHeight != null && _renderedHeight! > _threshold;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_renderedHeight == null) _measureImageHeight();
  }

  void _measureImageHeight() {
    final availableWidth = MediaQuery.of(context).size.width - 32;
    NetworkImage(widget.url, headers: const {'Referer': 'https://www.hoseo.ac.kr/'})
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, _) {
      if (!mounted) return;
      final rendered =
          info.image.height * availableWidth / info.image.width;
      setState(() => _renderedHeight = rendered);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final targetHeight = _isTall && !_expanded ? _threshold : _renderedHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: targetHeight,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft: Radius.circular(_isTall && !_expanded ? 0 : 10),
                bottomRight: Radius.circular(_isTall && !_expanded ? 0 : 10),
              ),
            ),
            child: Image.network(
              widget.url,
              fit: BoxFit.fitWidth,
              width: double.infinity,
              headers: const {'Referer': 'https://www.hoseo.ac.kr/'},
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 180,
                  color: const Color(0xFFF1F8F1),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32), strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, e, s) => const SizedBox.shrink(),
            ),
          ),
        ),
        if (_isTall)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                border: Border.all(color: const Color(0xFFBFDBFE)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _expanded ? '이미지 접기' : '이미지 전체 보기',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FullScreenImagePage extends StatelessWidget {
  final String url;
  const _FullScreenImagePage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('이미지 보기',
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            headers: const {'Referer': 'https://www.hoseo.ac.kr/'},
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              );
            },
            errorBuilder: (_, e, s) => const Center(
              child: Text('이미지를 불러올 수 없습니다.',
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
        ),
      ),
    );
  }
}
