import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
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

  static const Map<String, String> _responses = {
    '장학': '장학금 관련 공지는 [장학] 카테고리에서 확인하실 수 있습니다.\n현재 국가장학금 2차 신청 마감이 임박해 있습니다. 한국장학재단(www.kosaf.go.kr)에서 신청하세요!',
    '수강': '수강신청은 포털 → 학사 → 수강신청 메뉴에서 하실 수 있습니다.\n수강 정정 기간도 놓치지 마세요!',
    '취업': '취업 관련 공지는 [취업] 카테고리에서 확인하세요.\n교내 취업 취망자 신청, 하계 인턴십 등 다양한 취업 지원 프로그램이 있습니다.',
    '성적': '성적 이의신청은 [학사] 카테고리에서 공지를 확인하시고, 해당 교수님께 직접 문의하시면 됩니다.',
    '봉사': '사회봉사 활동은 [사회봉사] 카테고리에서 확인하세요.\n30시간 이상 활동 시 1학점이 인정됩니다!',
    '교양': '영역별 교양 강의는 [영역별교양] 카테고리에서 확인하실 수 있습니다.\n인문, 사회, 자연, 예술 등 다양한 강의가 개설되어 있습니다.',
    '창업': '창업 관련 공지는 [외부] 카테고리에서 확인하세요.\n교내 창업경진대회 참가자 모집 중입니다!',
  };

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: _getResponse(text), isUser: false, time: DateTime.now()));
      });
      _scrollToBottom();
    });
  }

  String _getResponse(String input) {
    for (final entry in _responses.entries) {
      if (input.contains(entry.key)) return entry.value;
    }
    return '죄송해요, 해당 내용은 아직 제가 답변하기 어렵습니다 😅\n공지사항 목록에서 직접 검색해 보시거나, 학교 포털(portal.hoseo.ac.kr)을 이용해 주세요!';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('호서 도우미', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('질문하면 답해드려요', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickChips(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) return _buildTypingIndicator();
                return _buildBubble(_messages[i]);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    final chips = ['장학금 안내', '수강신청', '취업 정보', '사회봉사'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: chips.map((chip) => GestureDetector(
            onTap: () {
              _controller.text = chip;
              _send();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(chip, style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500)),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1E3A8A) : Colors.white,
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
              child: Text(
                msg.text,
                style: TextStyle(fontSize: 14, height: 1.5, color: isUser ? Colors.white : const Color(0xFF1F2937)),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
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
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
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
                color: const Color(0xFFF4F6F9),
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
                onSubmitted: (_) => _send(),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
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
                color: Color.fromRGBO(30, 58, 138, opacity.clamp(0.3, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
