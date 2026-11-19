import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_component_tokens.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_tag.dart';
import '../app_top_bar.dart';

/// 채팅방 상단 바 종류 (Figma Top `Property 1`).
/// chat = 채팅창(1:1 문의방), jointPerformanceChat = 합동공연채팅(팀 대표 단체방).
enum ChatTopBarType { chat, jointPerformanceChat }

/// Figma `Top` 채팅창·합동공연채팅 (메시지). 채팅방 상단 바: 뒤로, 상대 이름과 부가 정보, 오른쪽 버튼.
///
/// - chat: 프로필 사진([image]), 문의 태그([tagLabel], 예: 보낸 문의), 더보기.
/// - jointPerformanceChat: 사진 없이 참여자 버튼([onMembers])과 더보기.
///
/// 버튼 이름(`*Tooltip`)은 화면 읽기 프로그램이 읽는다.
class ChatTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatTopBar({
    super.key,
    required this.type,
    required this.title,
    required this.subtitles,
    required this.backTooltip,
    required this.onBack,
    required this.moreTooltip,
    required this.onMore,
    this.image,
    this.tagLabel,
    this.membersTooltip,
    this.onMembers,
  }) : assert(
         type != ChatTopBarType.jointPerformanceChat || membersTooltip != null,
         '합동공연채팅은 참여자 버튼 이름(membersTooltip)이 필요하다.',
       );

  static const _height = 65.0; // Figma: 위아래 여백 10 + 버튼 44 + 아래 선 1
  static const _imageSize = 40.0; // Figma: ProfileS

  final ChatTopBarType type;

  /// 상대 이름 (예: 오프비트).
  final String title;

  /// 이름 아래 작은 글자들 (예: 1시간 내 답변 / 대표자 채팅, 참여 13명). 사이를 10 띄운다.
  final List<String> subtitles;
  final String backTooltip;
  final VoidCallback? onBack;
  final String moreTooltip;
  final VoidCallback? onMore;

  /// chat만: 상대 프로필 사진. null이면 회색 원.
  final ImageProvider? image;

  /// chat만: 오른쪽 태그 (예: 보낸 문의). null이면 그리지 않는다.
  final String? tagLabel;

  /// jointPerformanceChat만: 참여자 버튼.
  final String? membersTooltip;
  final VoidCallback? onMembers;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isChat = type == ChatTopBarType.chat;

    AppIconButton button(
      AppIcons icon,
      String tooltip,
      VoidCallback? onPressed,
    ) => AppIconButton(
      icon: AppIcon(icon, color: colors.gray800),
      tooltip: tooltip,
      onPressed: onPressed,
    );

    return Material(
      color: colors.backgroundNormal,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTopBarTokens.paddingX,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.lineNeutral)),
          ),
          child: Row(
            children: [
              button(AppIcons.arrowBack, backTooltip, onBack),
              const SizedBox(width: AppSpacing.x2_5),
              if (isChat) ...[
                CircleAvatar(
                  radius: _imageSize / 2,
                  backgroundColor: colors.fillStrong,
                  backgroundImage: image,
                ),
                const SizedBox(width: AppSpacing.x2_5),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.x0_5,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.body1SemiBold.copyWith(
                        color: colors.labelNormal,
                      ),
                    ),
                    Row(
                      spacing: AppSpacing.x2_5,
                      children: [
                        for (final text in subtitles)
                          Flexible(
                            child: Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyles.caption1Regular.copyWith(
                                color: colors.labelAlternative,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (tagLabel case final label? when isChat) ...[
                const SizedBox(width: AppSpacing.x2),
                AppRoundTag(label: label),
              ],
              if (membersTooltip case final tooltip? when !isChat)
                button(AppIcons.my, tooltip, onMembers),
              button(AppIcons.more, moreTooltip, onMore),
            ],
          ),
        ),
      ),
    );
  }
}
