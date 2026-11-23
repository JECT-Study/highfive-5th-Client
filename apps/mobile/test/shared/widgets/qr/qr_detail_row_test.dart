import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/qr/qr_detail_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      QrDetailRow(
        name: '김민수',
        phone: '010-****-1234',
        detail: '2매 | 소음공장',
        tagLabel: '남은 2명',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(QrDetailRow));

    expect(taps, 1);
  });

  testWidgets('태그 글자가 없으면 태그를 숨긴다', (tester) async {
    for (final (tagLabel, tags) in [(null, 0), ('남은 2명', 1)]) {
      await _pump(
        tester,
        QrDetailRow(
          name: '김민수',
          phone: '010-****-1234',
          detail: '2매 | 소음공장',
          tagLabel: tagLabel,
        ),
      );
      expect(find.byType(AppTag), findsNWidgets(tags), reason: '$tagLabel');
    }
  });
}
