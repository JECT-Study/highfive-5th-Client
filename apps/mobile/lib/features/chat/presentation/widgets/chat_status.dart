import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../models/chat_room.dart';

class ChatStatus extends StatelessWidget {
  const ChatStatus({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final reason = error is ChatException
        ? (error as ChatException).reason
        : null;
    final message = switch (reason) {
      ChatFailure.unavailable => '문의 채팅을 준비하고 있어요. 나중에 다시 확인해 주세요.',
      ChatFailure.sessionEnded => '채팅 세션이 종료됐어요. 메시지함에서 다시 열어 주세요.',
      ChatFailure.forbidden => '이 대화에 참여할 권한이 없어요. 메시지함을 확인해 주세요.',
      ChatFailure.roomMissing => '채팅방을 찾지 못했어요. 메시지함에서 다시 열어 주세요.',
      ChatFailure.emptyMessage => '메시지를 입력한 뒤 다시 보내 주세요.',
      null => '채팅을 불러오지 못했어요. 다시 시도해 주세요.',
    };
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(liveRegion: true, child: Text(message)),
          if (onRetry != null) AppButton(label: '다시 시도', onPressed: onRetry),
        ],
      ),
    );
  }
}
