import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// 하단 탭 메시지 첫 화면. 대화 목록은 채팅 기능 작업에서 채운다.
class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Text('메시지', style: context.textStyles.head),
        ),
      ),
    );
  }
}
