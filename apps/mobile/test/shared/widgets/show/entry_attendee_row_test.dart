import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/entry_attendee_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('입장 버튼과 화살표는 각자 자기 콜백을 부른다', (tester) async {
    var enters = 0;
    var details = 0;
    await _pump(
      tester,
      EntryAttendeeRow(
        name: '정우성',
        phone: '010-8888-1234',
        details: const ['2매', '소음공장'],
        enterLabel: '2명',
        onEnter: () => enters++,
        detailTooltip: '신청 자세히 보기',
        onDetail: () => details++,
      ),
    );

    await tester.tap(find.text('2명'));
    await tester.tap(find.byTooltip('신청 자세히 보기'));

    expect(enters, 1);
    expect(details, 1);
  });
}
