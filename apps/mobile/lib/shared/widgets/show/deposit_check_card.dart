import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_selection_controls.dart';
import '../app_tag.dart';

/// 입금 확인 상태 (Figma `Property 1`). 상태에 따라 오른쪽 아래 버튼의 중요도가 바뀐다.
enum DepositCheckStatus {
  /// 확인완료: 입금을 확인했다. 되돌리는 버튼(Weak).
  confirmed,

  /// 미확인: 입금 확인을 기다린다. 확인 버튼(Fill)과 자동 취소 안내.
  unconfirmed,

  /// 미입금: 입금하지 않았다. 티켓 취소 버튼(Danger).
  unpaid,

  /// 취소신청: 신청자가 취소를 요청했다. 티켓 취소 버튼(Danger).
  cancelRequested,
}

/// Figma `입금확인` (show). 대표자가 신청자의 입금을 확인하는 목록 한 줄: 체크박스, 이름·태그·금액, 신청 정보, 버튼.
///
/// 버튼은 쓰기 명령(입금 확인·티켓 취소)이므로 요청 중에는 ViewModel의 상태를 [loading]으로 넘겨 다시 눌리지 않게 한다.
class DepositCheckCard extends StatelessWidget {
  const DepositCheckCard({
    super.key,
    required this.status,
    required this.name,
    required this.amount,
    required this.details,
    required this.actionLabel,
    required this.onAction,
    required this.checked,
    required this.onCheckedChanged,
    this.tagLabel,
    this.deadlineLabel,
    this.loading = false,
  });

  static const _deadlineIconSize = 14.0; // Figma: ep:timer 아이콘

  final DepositCheckStatus status;
  final String name;

  /// 금액, 단위까지 (예: 30,000원).
  final String amount;

  /// 이름 아래 회색 줄. 점으로 이어 보인다 (예: 신청자 정우성, 4321).
  final List<String> details;

  /// 이름 옆 태그 (예: 입금 확인, 미입금). Figma 설명대로 한 번에 하나만 둔다.
  final String? tagLabel;

  /// 자동 취소까지 남은 시간 안내 (Figma 미확인의 타이머 줄).
  final String? deadlineLabel;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool loading;
  final bool checked;
  final ValueChanged<bool>? onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final strong = textStyles.title2SemiBold.copyWith(
      color: colors.labelNormal,
    );
    final caption = textStyles.caption1Regular.copyWith(
      color: colors.labelAlternative,
    );
    final tagLabel = this.tagLabel;
    final deadlineLabel = this.deadlineLabel;
    final variant = switch (status) {
      DepositCheckStatus.confirmed => AppButtonVariant.weak,
      DepositCheckStatus.unconfirmed => AppButtonVariant.fill,
      DepositCheckStatus.unpaid ||
      DepositCheckStatus.cancelRequested => AppButtonVariant.danger,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lineNeutral)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.x2_5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCheckbox(
              checked: checked,
              onChanged: onCheckedChanged,
              semanticLabel: name,
            ),
            Expanded(
              child: Padding(
                // 체크박스 누르는 영역(44)의 가운데에 이름 줄을 맞춘다. Figma는 체크박스 칸 22 + 위 여백 4.
                padding: const EdgeInsets.only(top: AppSpacing.x3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.x2_5,
                  children: [
                    Row(
                      spacing: AppSpacing.x2,
                      children: [
                        Expanded(
                          child: Row(
                            spacing: AppSpacing.x1_5,
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: strong,
                                ),
                              ),
                              if (tagLabel != null) AppTag(label: tagLabel),
                            ],
                          ),
                        ),
                        Text(amount, maxLines: 1, style: strong),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          spacing: AppSpacing.x2,
                          children: [
                            for (final (i, detail) in details.indexed) ...[
                              if (i > 0) const _Dot(),
                              Flexible(
                                child: Text(
                                  detail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: caption,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: deadlineLabel == null
                                  ? const SizedBox.shrink()
                                  : Row(
                                      spacing: AppSpacing.x1,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: _deadlineIconSize,
                                          color: colors.labelNormal,
                                        ),
                                        Flexible(
                                          child: Text(
                                            deadlineLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textStyles.caption1Regular
                                                .copyWith(
                                                  color: colors.labelNormal,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            AppButton(
                              label: actionLabel,
                              onPressed: onAction,
                              variant: variant,
                              size: AppButtonSize.small,
                              loading: loading,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma `Ellipse` 2 × 2 점. 회색 글자 사이를 나눈다.
class _Dot extends StatelessWidget {
  const _Dot();

  static const _size = 2.0; // Figma: Ellipse 2 × 2

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: context.colors.labelAlternative,
        shape: BoxShape.circle,
      ),
    );
  }
}
