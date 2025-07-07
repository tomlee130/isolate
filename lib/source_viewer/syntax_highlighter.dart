import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

class SyntaxHighlighterView extends StatelessWidget {
  final String code;
  final String language;

  const SyntaxHighlighterView({super.key, required this.code, required this.language});

  @override
  Widget build(BuildContext context) {
    return HighlightView(
      code,
      language: language,
      theme: githubTheme,
      padding: const EdgeInsets.all(12),
      textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
    );
  }
}
