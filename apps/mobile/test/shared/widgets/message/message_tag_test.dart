import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/message_tag.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('상태 글자가 있을 때만 앞에 상태 태그를 붙인다', (tester) async {
    await _pump(tester, const MessageTag(label: '보낸 문의', statusLabel: '거절됨'));
    expect(find.text('거절됨'), findsOneWidget);
    expect(find.text('보낸 문의'), findsOneWidget);

    await _pump(tester, const MessageTag(label: '보낸 문의'));
    expect(find.text('거절됨'), findsNothing);
    expect(find.text('보낸 문의'), findsOneWidget);
  });
}
