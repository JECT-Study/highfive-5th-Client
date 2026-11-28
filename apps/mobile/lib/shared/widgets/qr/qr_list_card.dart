import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// [QrListCard]의 한 줄: 왼쪽 이름, 오른쪽 값.
typedef QrListCardRow = ({String label, String value});

/// Figma `QRList` (qr). 티켓 가격·입금 계좌·예금주·신청 마감처럼 이름과 값을 줄지어 보여 주는 회색 카드.
class QrListCard extends StatelessWidget {
  const QrListCard({super.key, required this.rows});

  static const _paddingX = 18.0; // Figma: 좌우 여백 18 (간격 토큰 16과 20 사이)

  final List<QrListCardRow> rows;

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
        padding: const EdgeInsets.symmetric(
          horizontal: _paddingX,
          vertical: AppSpacing.x3_5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x2_5,
          children: [
            for (final row in rows)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.x3,
                children: [
                  Text(
                    row.label,
                    maxLines: 1,
                    style: style.copyWith(color: colors.labelAlternative),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
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
