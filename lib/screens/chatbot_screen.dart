import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import '../models/notice.dart';
import '../widgets/link_text.dart';
import 'notice_detail_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<Map<String, dynamic>> references;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.references = const [],
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '안녕하세요! 호서대학교 공지사항 도우미입니다 😊\n궁금한 것이 있으면 편하게 물어보세요!',
      isUser: false,
      time: DateTime.now(),
    ),
  ];
  bool _isTyping = false;


  static const List<Map<String, dynamic>> _quickChips = [
    {'icon': Icons.school_outlined, 'label': '장학금 안내'},
    {'icon': Icons.calendar_month_outlined, 'label': '수강신청'},
    {'icon': Icons.business_center_outlined, 'label': '취업 정보'},
    {'icon': Icons.volunteer_activism_outlined, 'label': '사회봉사'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final result = await ChatbotService.chat(text);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: result.answer,
          isUser: false,
          time: DateTime.now(),
          references: result.references,
        ));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: '서버 연결에 실패했습니다. 잠시 후 다시 시도해 주세요.',
          isUser: false,
          time: DateTime.now(),
        ));
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          _buildPageHeader(),
          _buildQuickChipBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == 0) return _buildTypingIndicator();
                final msgIndex = _messages.length - 1 - (i - (_isTyping ? 1 : 0));
                return _buildBubble(_messages[msgIndex]);
              },
            ),
          ),
          _buildInput(),
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFF1E3A5F), shape: BoxShape.circle),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('호서 도우미',
                      style: TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: Color(0xFF22C55E)),
                      SizedBox(width: 4),
                      Text('온라인',
                          style: TextStyle(color: Color(0xFF22C55E), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
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

  Widget _buildQuickChipBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickChips.map((chip) {
            return GestureDetector(
              onTap: () {
                _controller.text = chip['label'] as String;
                _send();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(chip['icon'] as IconData, size: 14, color: const Color(0xFF1E3A5F)),
                    const SizedBox(width: 6),
                    Text(chip['label'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: Color(0xFF1E3A5F), shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF1E3A5F) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: LinkText(
                    msg.text,
                    style: TextStyle(fontSize: 14, height: 1.5, color: isUser ? Colors.white : const Color(0xFF1F2937)),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 4),
            ],
          ),
          if (!isUser && msg.references.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Column(
                children: msg.references
                    .map((ref) => _buildNoticeCard(ref))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoticeCard(Map<String, dynamic> ref) {
    final articleId = ref['article_id']?.toString() ?? '';
    final detailUrl = ref['detail_url'] as String? ??
        (articleId.isNotEmpty
            ? 'https://www.hoseo.ac.kr/Home/BBSView.mbz'
                '?action=MAPP_1708240139'
                '&schIdx=$articleId'
                '&schCategorycode=CTG_17082400011'
                '&schKeytype=subject&schKeyword=&pageIndex=1'
            : null);
    final notice = Notice(
      id: articleId,
      articleId: int.tryParse(articleId),
      title: ref['title'] as String? ?? '',
      department: ref['writer'] as String? ?? '',
      date: ref['date'] as String? ?? '',
      category: ref['category'] as String? ?? '공지사항',
      content: ref['content'] as String?,
      detailUrl: detailUrl,
    );
    final color = Notice.categoryColor(notice.category);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(notice.category,
                        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.title,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF111827), fontWeight: FontWeight.w500, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: Color(0xFF1E3A5F), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) async => _send(),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _send(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: Color(0xFF1E3A5F), shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, v) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = value < 0.5 ? value * 2 : (1.0 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Color.fromRGBO(15, 30, 61, opacity.clamp(0.3, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
