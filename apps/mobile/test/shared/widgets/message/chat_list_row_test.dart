import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/message/chat_list_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('대표자 글자가 있을 때만 이름 옆에 태그를 붙인다', (tester) async {
    await _pump(tester, const ChatListRow(name: '조하은', leaderLabel: '대표자'));
    expect(find.byType(AppRoundTag), findsOneWidget);

    await _pump(tester, const ChatListRow(name: '조하은'));
    expect(find.byType(AppRoundTag), findsNothing);
  });
}
