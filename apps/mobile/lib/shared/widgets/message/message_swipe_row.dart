import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma `MessageSwipeRow` (메시지). 목록 한 줄을 왼쪽으로 밀면 오른쪽에 빨간 행동 버튼(예: 나가기)이 나온다.
///
/// 열림 여부 [revealed]는 쓰는 쪽이 가진다 (Figma `Property 1`: Default = 닫힘, Swipe = 열림).
/// 왼쪽으로 밀면 `onRevealedChanged(true)`, 오른쪽으로 밀면 `false`를 부른다.
/// 손가락을 따라 움직이지는 않고 열림·닫힘 사이를 짧게 움직인다.
/// 밀기를 못 쓰는 화면 읽기 프로그램 사용자를 위해 같은 행동을 화면의 다른 메뉴에도 둔다.
class MessageSwipeRow extends StatelessWidget {
  const MessageSwipeRow({
    super.key,
    required this.actionLabel,
    required this.onAction,
    required this.child,
    this.revealed = false,
    this.onRevealedChanged,
  });

  static const _actionWidth = 128.0; // Figma: 나가기 버튼 폭

  /// 오른쪽 빨간 버튼 글자 (예: 나가기).
  final String actionLabel;
  final VoidCallback? onAction;

  /// 미는 줄. 보통 `InquiryListItem`.
  final Widget child;
  final bool revealed;
  final ValueChanged<bool>? onRevealedChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = onRevealedChanged;
    // Figma: 줄과 버튼 사이 10.
    const shift = _actionWidth + AppSpacing.x2_5;

    return GestureDetector(
      onHorizontalDragEnd: onChanged == null
          ? null
          : (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity != 0) onChanged(velocity < 0);
            },
      child: ClipRect(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: revealed ? 1 : 0),
          duration: kThemeAnimationDuration,
          curve: Curves.easeOut,
          builder: (context, progress, row) => Stack(
            children: [
              if (progress > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: _actionWidth,
                  child: _SwipeAction(label: actionLabel, onTap: onAction),
                ),
              Transform.translate(
                offset: Offset(-shift * progress, 0),
                child: row,
              ),
            ],
          ),
          // 닫혀 있을 때 뒤의 버튼을 가린다. Material이라 줄의 눌림 효과도 보인다.
          child: Material(color: context.colors.backgroundNormal, child: child),
        ),
      ),
    );
  }
}

/// 밀면 나오는 빨간 버튼 (Figma 나가기).
class _SwipeAction extends StatelessWidget {
  const _SwipeAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: Material(
        color: colors.statusDestructive,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x2_5),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.body1Medium.copyWith(
                  color: colors.staticWhite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
