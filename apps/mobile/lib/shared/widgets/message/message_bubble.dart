import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_tag.dart';

/// 말풍선 방향 (Figma MessageContainer `Property 1`).
/// sent = Sent(내가 보냄, 오른쪽), received = Received(받음, 왼쪽).
enum MessageBubbleDirection { sent, received }

/// Figma `MessageContainer` (메시지). 채팅 말풍선 하나와 보낸 시각.
///
/// 받은 말풍선 위에는 보낸 사람 이름([senderName], Figma Show Band Name)과
/// 밴드 태그([bandLabel], Show Band Tag)를 붙인다.
/// Figma 설명: 합동공연 팀 채팅은 밴드 태그를 켜고 문의 채팅은 끈다. 팀 채팅에서 우리 팀 메시지는 이름만 보인다.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.direction,
    required this.message,
    required this.time,
    this.senderName,
    this.bandLabel,
  });

  static const _paddingX = 18.0; // Figma: 말풍선 좌우 여백

  final MessageBubbleDirection direction;
  final String message;

  /// 보낸 시각 (예: 오후3:31).
  final String time;

  /// 받은 말풍선 위 보낸 사람 이름. 보낸 말풍선에는 그리지 않는다.
  final String? senderName;

  /// 이름 옆 밴드 태그 (예: 오프비트 대표). [senderName]이 있을 때만 보인다.
  final String? bandLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final sent = direction == MessageBubbleDirection.sent;
    const corner = Radius.circular(AppRadius.lg);

    // Figma: 보낸 말풍선은 오른쪽 아래, 받은 말풍선은 왼쪽 아래 모서리만 각지다.
    // 보낸 말풍선의 테두리는 바탕과 같은 색이라 그리지 않는다.
    final decoration = sent
        ? BoxDecoration(
            color: colors.fillStrong,
            borderRadius: const BorderRadius.only(
              topLeft: corner,
              topRight: corner,
              bottomLeft: corner,
            ),
          )
        : BoxDecoration(
            color: colors.fillNormal,
            border: Border.all(color: colors.lineNeutral),
            borderRadius: const BorderRadius.only(
              topLeft: corner,
              topRight: corner,
              bottomRight: corner,
            ),
          );

    return Column(
      crossAxisAlignment: sent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      spacing: AppSpacing.x1,
      children: [
        if (senderName case final name? when !sent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2_5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.x1_5,
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.caption1Regular.copyWith(
                      color: colors.labelStrong,
                    ),
                  ),
                ),
                if (bandLabel case final band?)
                  AppTag(label: band, size: AppTagSize.large),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _paddingX,
            vertical: AppSpacing.x3_5,
          ),
          decoration: decoration,
          child: Text(
            message,
            style: textStyles.body1Regular.copyWith(color: colors.labelNormal),
          ),
        ),
        Text(
          time,
          style: textStyles.caption1Regular.copyWith(
            color: colors.labelAlternative,
          ),
        ),
      ],
    );
  }
}
