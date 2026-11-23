import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_component_tokens.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_top_bar.dart';
import 'show_meta_text.dart';

/// Figma `Top` (공연페이지). `Property 1 = 합동공연`: 합동공연 화면 상단 바. 뒤로, 포스터·공연 이름·정보, 채팅.
class ShowTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ShowTopBar({
    super.key,
    required this.title,
    required this.backTooltip,
    required this.onBack,
    required this.chatTooltip,
    required this.onChatTap,
    this.details = const [],
    this.poster,
  });

  /// 공연 이름 (예: 소음공장 합동공연).
  final String title;

  /// 이름 아래 점으로 나눈 정보 (예: 10/12(월), 팀 모집 중).
  final List<String> details;

  final ImageProvider? poster;

  /// 뒤로 버튼을 읽어 주는 이름 (예: 뒤로).
  final String backTooltip;
  final VoidCallback? onBack;

  /// 채팅 버튼을 읽어 주는 이름 (예: 채팅).
  final String chatTooltip;
  final VoidCallback? onChatTap;

  static const _posterSize = 40.0; // Figma: 포스터 이미지 폭

  @override
  Size get preferredSize => const Size.fromHeight(AppTopBarTokens.height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.backgroundNormal,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppTopBarTokens.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTopBarTokens.paddingX,
            ),
            child: Row(
              children: [
                AppIconButton(
                  icon: const AppIcon(AppIcons.arrowBack),
                  tooltip: backTooltip,
                  onPressed: onBack,
                ),
                Expanded(
                  child: Row(
                    spacing: AppSpacing.x3_5,
                    children: [
                      Container(
                        width: _posterSize,
                        height: _posterSize,
                        decoration: BoxDecoration(
                          color: colors.fillStrong,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          image: poster == null
                              ? null
                              : DecorationImage(
                                  image: poster!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSpacing.x1_5,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.body1Bold.copyWith(
                                color: colors.labelNormal,
                              ),
                            ),
                            if (details.isNotEmpty) ShowMetaText(details),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: const AppIcon(AppIcons.message),
                  tooltip: chatTooltip,
                  onPressed: onChatTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `Top` (공연페이지). `Property 1 = 현장입장`: 현장 입장 화면의 어두운 상단 바. 닫기와 가운데 제목·공연 정보.
class EntryTopBar extends StatelessWidget implements PreferredSizeWidget {
  const EntryTopBar({
    super.key,
    required this.title,
    required this.closeTooltip,
    required this.onClose,
    this.details = const [],
  });

  /// 가운데 제목 (예: 현장 입장).
  final String title;

  /// 제목 아래 점으로 나눈 정보 (예: 소음공장 합동공연, 오늘 19:00).
  final List<String> details;

  /// 닫기 버튼을 읽어 주는 이름 (예: 닫기).
  final String closeTooltip;
  final VoidCallback? onClose;

  @override
  Size get preferredSize => const Size.fromHeight(AppTopBarTokens.height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.inverseBackground,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppTopBarTokens.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTopBarTokens.paddingX,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTopBarTokens.iconButtonSize,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.textStyles.title2Bold.copyWith(
                          color: colors.staticWhite,
                        ),
                      ),
                      if (details.isNotEmpty)
                        ShowMetaText(details, onDark: true),
                    ],
                  ),
                ),
                Row(
                  children: [
                    AppIconButton(
                      icon: AppIcon(AppIcons.close, color: colors.staticWhite),
                      tooltip: closeTooltip,
                      onPressed: onClose,
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
