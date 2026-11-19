import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_selection_controls.dart';
import 'profile_badge.dart';

/// Figma `MessageItem_Inquiry` (메시지). 메시지 목록의 채팅방 한 줄: 프로필, 밴드 이름, 공고 제목, 태그, 마지막 메시지와 시각.
///
/// Figma `Property 1`:
/// - Default: [subtitle](공고 제목)과 [tag](보통 `MessageTag`)를 넣는다.
/// - 공고삭제: [postDeleted] = true. 줄 전체가 흐려지고 [subtitle]에 `삭제된 공고` 같은 글자를 넣는다.
/// - 목록에서 확인: [subtitle]과 [tag]를 넣지 않는다.
///
/// 편집 중 여러 개 고르기는 [showCheckbox]·[checked]·[onCheckedChanged] (Figma showCheckBox).
class InquiryListItem extends StatelessWidget {
  const InquiryListItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.subtitle,
    this.tag,
    this.image,
    this.unreadCount = 0,
    this.postDeleted = false,
    this.showCheckbox = false,
    this.checked = false,
    this.onCheckedChanged,
    this.onTap,
  });

  static const _deletedOpacity = 0.5; // Figma: 공고삭제 줄 불투명도 50%
  static const _messageLineHeight = 18.0; // Figma: 마지막 메시지 줄 높이

  /// 밴드(상대) 이름.
  final String name;

  /// 마지막 메시지. 한 줄을 넘으면 말줄임.
  final String message;

  /// 마지막 메시지 시각 (예: 오후 3:31).
  final String time;

  /// 이름 아래 작은 글자 (예: 공고 제목, 삭제된 공고).
  final String? subtitle;

  /// 오른쪽 위 태그. 보통 `MessageTag`.
  final Widget? tag;

  /// 프로필 사진. null이면 회색 원.
  final ImageProvider? image;

  /// 안 읽은 메시지 수. 0이면 숫자를 숨긴다.
  final int unreadCount;
  final bool postDeleted;
  final bool showCheckbox;
  final bool checked;
  final ValueChanged<bool>? onCheckedChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    Widget row = Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x2_5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lineNeutral)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCheckbox)
            AppCheckbox(checked: checked, onChanged: onCheckedChanged),
          ProfileBadge(image: image, count: unreadCount),
          const SizedBox(width: AppSpacing.x4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.x1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // Figma: 공고삭제는 위아래 줄 사이가 더 넓다.
                spacing: postDeleted ? AppSpacing.x2_5 : AppSpacing.x1_5,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.x2,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSpacing.x0_5,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyles.body1SemiBold.copyWith(
                                color: colors.labelNormal,
                              ),
                            ),
                            if (subtitle case final text?)
                              Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.caption1Medium.copyWith(
                                  color: colors.labelAlternative,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ?tag,
                    ],
                  ),
                  SizedBox(
                    height: _messageLineHeight,
                    child: Row(
                      spacing: AppSpacing.x1_5,
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textStyles.caption1Regular.copyWith(
                              color: colors.labelNormal,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: textStyles.caption1Regular.copyWith(
                            color: colors.labelAlternative,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (postDeleted) row = Opacity(opacity: _deletedOpacity, child: row);

    return Semantics(
      button: onTap != null,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
