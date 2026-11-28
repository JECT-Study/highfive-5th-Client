import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// [QrListCard]의 한 줄: 왼쪽 이름, 오른쪽 값.
typedef QrListCardRow = ({String label, String value});

/// Figma `QRList` (qr). 티켓 가격·입금 계좌·예금주·신청 마감처럼 이름과 값을 줄지어 보여 주는 회색 카드.
class QrListCard extends StatelessWidget {
  const QrListCard({super.key, required this.rows})
    : _paddingX = 18,
      _rowGap = AppSpacing.x3;

  /// V3 SummaryBox(2014:19752). Dialog 내용 슬롯 등에 넣는 303 × 108의 세 줄 예시.
  /// QR 카드와 표시·말줄임·테마를 공유하고 실제 차이인 좌우 여백과 열 간격만 바꾼다.
  const QrListCard.summary({super.key, required this.rows})
    : _paddingX = AppSpacing.x4,
      _rowGap = 0;

  final List<QrListCardRow> rows;
  final double _paddingX;
  final double _rowGap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.body1Medium;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _paddingX,
          vertical: AppSpacing.x3_5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x2_5,
          children: [
            for (final row in rows)
              Row(
                spacing: _rowGap,
                children: [
                  Text(
                    row.label,
                    maxLines: 1,
                    style: style.copyWith(color: colors.labelAlternative),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: style.copyWith(color: colors.labelNormal),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
