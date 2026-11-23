import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/invitation_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('거절·수락 버튼이 각자의 콜백을 부른다', (tester) async {
    var declines = 0;
    var accepts = 0;
    await _pump(
      tester,
      InvitationCard(
        title: '오프비트와 함께 공연할까요?',
        declineLabel: '거절하기',
        acceptLabel: '함께 공연하기',
        onDecline: () => declines++,
        onAccept: () => accepts++,
      ),
    );

    await tester.tap(find.text('거절하기'));
    expect((declines, accepts), (1, 0));

    await tester.tap(find.text('함께 공연하기'));
    expect((declines, accepts), (1, 1));
  });

  testWidgets('콜백이 없으면 두 버튼 모두 비활성으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const InvitationCard(
        title: '오프비트와 함께 공연할까요?',
        declineLabel: '거절하기',
        acceptLabel: '함께 공연하기',
        onDecline: null,
        onAccept: null,
      ),
    );

    for (final label in ['거절하기', '함께 공연하기']) {
      expect(
        tester.getSemantics(find.text(label)),
        isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
        reason: label,
      );
    }
    semantics.dispose();
  });
}
