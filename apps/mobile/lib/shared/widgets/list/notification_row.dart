import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_selection_controls.dart';

/// Figma `Notification` (목록). 알림 목록에서 알림 하나를 보여 주는 줄 (Property 1 = Default · New).
class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.unread = false,
    this.onTap,
  });

  /// 왼쪽 동그라미 안 아이콘 (Figma `message`).
  final AppIcons icon;
  final String title;

  /// 알림 내용. 두 줄까지 보이고 넘치면 끝을 줄인다.
  final String message;

  /// 받은 때 (예: `방금`).
  final String time;

  /// 안 읽은 알림 (Figma New): 회색 바탕과 제목 옆 분홍 점.
  final bool unread;
  final VoidCallback? onTap;

  static const _iconCircleSize = 38.0; // Figma: notice 동그라미 지름
  static const _gap = 18.0; // Figma: 동그라미·글·시간 사이
  static const _unreadDotSize = 7.0; // Figma: 안 읽음 점 지름

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Semantics(
      button: onTap != null,
      child: Material(
        type: unread ? MaterialType.canvas : MaterialType.transparency,
        color: unread ? colors.backgroundAlternative : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x5,
              vertical: AppSpacing.x4,
            ),
            // Figma: 아이콘·글은 가운데, 시간은 줄 맨 위에 붙는다.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: _gap,
                children: [
                  Center(
                    child: Container(
                      width: _iconCircleSize,
                      height: _iconCircleSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.fillStrong,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(icon, color: colors.labelNeutral),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.x0_5,
                      children: [
                        Row(
                          spacing: AppSpacing.x1_5,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.body1Medium.copyWith(
                                  color: colors.gray800,
                                ),
                              ),
                            ),
                            if (unread)
                              Container(
                                key: const ValueKey(
                                  'notificationRow_unreadDot',
                                ),
                                width: _unreadDotSize,
                                height: _unreadDotSize,
                                decoration: BoxDecoration(
                                  color: colors.pink600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.caption1Medium.copyWith(
                            color: colors.labelNeutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: textStyles.tag2.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `Notification`의 Property 1 = toggle · text · next (오른쪽 요소의 종류).
enum _SettingTrailing { toggle, text, next }

/// Figma `Notification` (목록). 알림 설정 화면에서 제목과 토글·값·화살표를 보여 주는 줄 (Property 1 = toggle · text · next).
class NotificationSettingRow extends StatelessWidget {
  /// Property 1 = toggle. 오른쪽 [AppToggle]로 켜고 끈다.
  const NotificationSettingRow.toggle({
    super.key,
    required this.title,
    required this.checked,
    required this.onChanged,
  }) : value = null,
       onTap = null,
       _trailing = _SettingTrailing.toggle;

  /// Property 1 = text. 오른쪽에 [value]를 보인다.
  const NotificationSettingRow.text({
    super.key,
    required this.title,
    required String this.value,
    this.onTap,
  }) : checked = false,
       onChanged = null,
       _trailing = _SettingTrailing.text;

  /// Property 1 = next. 오른쪽 화살표, 누르면 다음 화면으로 간다.
  const NotificationSettingRow.next({
    super.key,
    required this.title,
    required this.onTap,
  }) : checked = false,
       onChanged = null,
       value = null,
       _trailing = _SettingTrailing.next;

  final String title;

  /// toggle에서 켜져 있는지.
  final bool checked;

  /// toggle을 누르면 바뀔 값을 넘긴다. null이면 비활성.
  final ValueChanged<bool>? onChanged;

  /// text에서 오른쪽에 보이는 짧은 값 (예: `카카오톡`).
  final String? value;

  /// text·next 줄을 누를 때. null이면 누를 수 없다.
  final VoidCallback? onTap;
  final _SettingTrailing _trailing;

  // Figma: 줄 높이 56 (Toggle 52 + 위아래 2, 글자 줄은 위아래 18).
  static const _minHeight = 56.0;
  static const _trailingGap = 28.0; // Figma: 제목과 오른쪽 요소 사이
  static const _arrowSize = 20.0; // Figma: arrow

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final trailing = switch (_trailing) {
      _SettingTrailing.toggle => AppToggle(
        checked: checked,
        onChanged: onChanged,
        semanticLabel: title,
      ),
      _SettingTrailing.text => Text(
        value!,
        maxLines: 1,
        style: textStyles.body1SemiBold.copyWith(color: colors.labelNeutral),
      ),
      // 오른쪽 화살표는 chevronLeft를 좌우로 뒤집어 쓴다.
      _SettingTrailing.next => Transform.flip(
        flipX: true,
        child: AppIcon(
          AppIcons.chevronLeft,
          size: _arrowSize,
          color: colors.labelAlternative,
        ),
      ),
    };

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
        child: Row(
          spacing: _trailingGap,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyles.title2SemiBold.copyWith(
                  color: colors.gray800,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );

    if (_trailing == _SettingTrailing.toggle) return row;
    return Semantics(
      button: onTap != null,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
