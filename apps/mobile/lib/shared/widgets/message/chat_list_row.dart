import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_tag.dart';

/// Figma `ChatListRow` (메시지). 채팅방 참여자 목록 한 줄: 프로필, 이름, 대표자 태그.
class ChatListRow extends StatelessWidget {
  const ChatListRow({
    super.key,
    required this.name,
    this.image,
    this.leaderLabel,
  });

  static const _imageSize = 38.0; // Figma: 참여자 프로필

  final String name;

  /// 프로필 사진. null이면 회색 원을 그린다.
  final ImageProvider? image;

  /// 이름 옆 태그 (예: 대표자). null이면 그리지 않는다 (Figma showLeaderTag).
  final String? leaderLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      spacing: AppSpacing.x2_5,
      children: [
        CircleAvatar(
          radius: _imageSize / 2,
          backgroundColor: colors.fillStrong,
          backgroundImage: image,
        ),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.body1Medium.copyWith(
              color: colors.labelNormal,
            ),
          ),
        ),
        if (leaderLabel case final label?) AppRoundTag(label: label),
      ],
    );
  }
}
