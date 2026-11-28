import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/qr/qr_list_card.dart';

void main() {
  testWidgets('SummaryBox는 QR 카드와 줄을 공유하되 좌우 여백만 16으로 둔다', (tester) async {
    const rows = [
      (label: '신청 금액', value: '30,000원 (2매)'),
      (label: '입금자명', value: '정우성'),
      (label: '취소 요청', value: '10.16'),
    ];
    for (final summary in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 303,
                child: summary
                    ? const QrListCard.summary(rows: rows)
                    : const QrListCard(rows: rows),
              ),
            ),
          ),
        ),
      );

      final card = tester.getRect(find.byType(QrListCard));
      final label = tester.getRect(find.text(rows.first.label));
      final value = tester.getRect(find.text(rows.first.value));
      expect(label.left - card.left, summary ? 16 : 18);
      expect(card.right - value.right, summary ? 16 : 18);
      // V3 SummaryBox 2014:19752: 3줄, 20 행 높이, 간격 10, 위아래 14.
      expect(card.height, 108);
    }
  });
}
