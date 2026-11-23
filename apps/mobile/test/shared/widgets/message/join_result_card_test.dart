import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/join_result_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('버튼을 누르면 onAction을 부른다', (tester) async {
    var actions = 0;
    await _pump(
      tester,
      JoinResultCard(
        title: '오프비트가 합류했어요!',
        message: '합동 공연 페이지에서 일정을 등록해보세요!',
        actionLabel: '합동 공연 페이지 가기',
        onAction: () => actions++,
      ),
    );

    await tester.tap(find.text('합동 공연 페이지 가기'));

    expect(actions, 1);
  });
}
