import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_component_tokens.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_top_bar.dart';

/// Figma `MessageInput` (메시지). 채팅방 아래 둥근 메시지 입력창과 보내기 버튼.
///
/// Figma 입력전·입력후는 [controller]에 글자가 있는지로 저절로 바뀐다.
/// 보내기는 공백이 아닌 글자가 있을 때만 눌린다. 보내는 중에는 [onSend]를 null로 넘겨 두 번 보내지 않게 하고,
/// 보낸 뒤 입력창 비우기는 쓰는 쪽이 한다.
/// 공통 `AppTextField`는 모서리가 10으로 고정이라, Figma의 양끝 둥근 입력창을 입력창 토큰으로 직접 그린다.
class MessageInputBar extends StatelessWidget {
  const MessageInputBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.sendLabel,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;

  /// 보내기 버튼 이름. 화면 읽기 프로그램이 읽고, 길게 누르면 보인다 (예: 보내기).
  final String sendLabel;
  final VoidCallback? onSend;

  /// false면 글자를 넣을 수 없다 (예: 팀 대표가 아닌 팀원).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = context.textStyles.body1Regular;
    return Container(
      height: AppInputTokens.height,
      padding: const EdgeInsets.symmetric(horizontal: AppInputTokens.paddingX),
      decoration: BoxDecoration(
        color: colors.backgroundNormal,
        border: Border.all(color: colors.lineStrong),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        spacing: AppInputTokens.gap,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: textStyle.copyWith(color: colors.labelNormal),
              cursorColor: colors.labelNormal,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: textStyle.copyWith(color: colors.labelAlternative),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => AppIconButton(
              icon: AppIcon(AppIcons.sendFill, color: colors.gray800),
              tooltip: sendLabel,
              onPressed: enabled && value.text.trim().isNotEmpty
                  ? onSend
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
