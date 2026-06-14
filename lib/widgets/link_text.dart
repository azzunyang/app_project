import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const LinkText(this.text, {super.key, this.style});

  static final _urlRegex = RegExp(r'https?://[^\s ]+', caseSensitive: false);

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final m in _urlRegex.allMatches(text)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, m.start), style: base));
      }
      final url = m.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: base.copyWith(
          color: const Color(0xFF2563EB),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF2563EB),
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _open(url),
      ));
      lastEnd = m.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: base));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
