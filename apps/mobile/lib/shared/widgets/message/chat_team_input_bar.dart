import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import 'message_input_bar.dart';

/// 팀 채팅에서 내 역할 (Figma MessageItem_Representative_Member `Property 1`).
/// representative = 대표자(입력 가능), member = 팀원(입력 불가).
enum ChatTeamRole { representative, member }

/// Figma `MessageItem_Representative_Member` (메시지). 합동공연 팀 채팅 화면 아래 입력 영역.
///
/// 팀 대표만 메시지를 보낼 수 있어 [role]이 member면 입력창과 보내기 버튼이 막힌다.
/// 역할마다 다른 안내 문구(예: 팀 대표만 입력 가능해요)는 [hintText]로 넘긴다. 아래쪽 홈 표시줄만큼 띄운다.
class ChatTeamInputBar extends StatelessWidget {
  const ChatTeamInputBar({
    super.key,
    required this.role,
    required this.controller,
    required this.hintText,
    required this.sendLabel,
    required this.onSend,
  });

  final ChatTeamRole role;
  final TextEditingController controller;
  final String hintText;

  /// 보내기 버튼 이름 (예: 보내기).
  final String sendLabel;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    final canWrite = role == ChatTeamRole.representative;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x5,
          vertical: AppSpacing.x2_5,
        ),
        child: MessageInputBar(
          controller: controller,
          hintText: hintText,
          sendLabel: sendLabel,
          onSend: canWrite ? onSend : null,
          enabled: canWrite,
        ),
      ),
    );
  }
}
