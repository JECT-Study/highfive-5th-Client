import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/message/message_bubble.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('받은 말풍선만 보낸 사람 이름과 밴드 태그를 보인다', (tester) async {
    for (final (direction, shown) in [
      (MessageBubbleDirection.received, true),
      (MessageBubbleDirection.sent, false),
    ]) {
      await _pump(
        tester,
        MessageBubble(
          direction: direction,
          message: '안녕하세요',
          time: '오후3:31',
          senderName: '만만수',
          bandLabel: '오프비트 대표',
        ),
      );
      final matcher = shown ? findsOneWidget : findsNothing;
      expect(find.text('만만수'), matcher, reason: '$direction');
      expect(find.byType(AppTag), matcher, reason: '$direction');
    }
  });

  testWidgets('보낸 사람 이름이 없으면 밴드 태그도 그리지 않는다', (tester) async {
    await _pump(
      tester,
      const MessageBubble(
        direction: MessageBubbleDirection.received,
        message: '안녕하세요',
        time: '오후3:31',
        bandLabel: '오프비트 대표',
      ),
    );

    expect(find.byType(AppTag), findsNothing);
  });
}
