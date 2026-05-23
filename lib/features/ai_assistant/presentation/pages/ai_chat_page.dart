import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

/// AI Assistant chat page.
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});
  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    _Msg(false, "Hi Pankaj! 👋 I noticed your hydration has been low for 3 days. Try keeping a water bottle at your desk."),
    _Msg(true, "Thanks! Will try that."),
    _Msg(false, "Great! I also noticed you sit too long between 10 AM–4 PM. Want me to set a walk reminder every hour?"),
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(true, text));
      _controller.clear();
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _messages.add(_Msg(false, "That's a great question! Based on your data, I'd recommend focusing on increasing your protein intake and maintaining your current hydration streak. 💪")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.secondaryGradient),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('INSIGHT AI', style: AppTypography.h3(color: AppColors.darkTextPrimary)),
                    Text('Your health assistant', style: AppTypography.caption(color: AppColors.darkTextSecondary)),
                  ]),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final msg = _messages[i];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: msg.isUser ? AppColors.primary.withValues(alpha: 0.15) : AppColors.darkSurface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                          bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                        ),
                        border: Border.all(color: msg.isUser ? AppColors.primary.withValues(alpha: 0.2) : AppColors.darkCardBorder),
                      ),
                      child: Text(msg.text, style: AppTypography.body(color: AppColors.darkTextPrimary)),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
                },
              ),
            ),

            // Quick chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _Chip('Set reminder', () {}),
                  const SizedBox(width: 8),
                  _Chip('My progress', () {}),
                  const SizedBox(width: 8),
                  _Chip('Diet tips', () {}),
                ]),
              ),
            ),

            // Input
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                border: Border(top: BorderSide(color: AppColors.darkDivider)),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppTypography.body(color: AppColors.darkTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask INSIGHT AI...',
                      hintStyle: AppTypography.body(color: AppColors.darkTextTertiary),
                      border: InputBorder.none, filled: false,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final bool isUser;
  final String text;
  _Msg(this.isUser, this.text);
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip(this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppTypography.bodySmall(color: AppColors.secondaryLight)),
      ),
    );
  }
}
