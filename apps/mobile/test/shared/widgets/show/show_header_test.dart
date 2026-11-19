import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/show/show_header.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('compact는 정보 수정 버튼을 보이고 누르면 onEdit을 부른다', (tester) async {
    var edits = 0;
    await _pump(
      tester,
      ShowHeader.compact(
        title: '소음공장 합동공연',
        statusLabel: '티켓 판매 중',
        editLabel: '정보 수정',
        onEdit: () => edits++,
      ),
    );

    await tester.tap(find.byType(AppButton));

    expect(edits, 1);
    expect(find.byType(ShowHeaderInfoRow), findsNothing);
  });

  testWidgets('기본 머리는 공연 정보 줄을 보이고 정보 수정 버튼은 없다', (tester) async {
    await _pump(
      tester,
      const ShowHeader(
        title: '소음공장 합동공연',
        statusLabel: '팀 모집 전',
        infoTitle: '공연 정보',
        infoRows: [
          ShowHeaderInfoRow(label: '날짜', value: '2026.10.12 (월)'),
          ShowHeaderInfoRow(label: '시간', value: '미정', pending: true),
        ],
      ),
    );

    expect(find.byType(ShowHeaderInfoRow), findsNWidgets(2));
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('D-day 태그는 값을 줄 때만 보인다', (tester) async {
    for (final (dDayLabel, tags) in [(null, 1), ('D - 10', 2)]) {
      await _pump(
        tester,
        ShowHeader.compact(
          title: '소음공장 합동공연',
          statusLabel: '티켓 판매 중',
          dDayLabel: dDayLabel,
          editLabel: '정보 수정',
          onEdit: () {},
        ),
      );
      expect(find.byType(AppTag), findsNWidgets(tags), reason: '$dDayLabel');
    }
  });
}
