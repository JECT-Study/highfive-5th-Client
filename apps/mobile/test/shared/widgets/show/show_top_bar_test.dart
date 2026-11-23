import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_top_bar.dart';

Future<void> _pump(WidgetTester tester, PreferredSizeWidget bar) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(appBar: bar),
      ),
    );

void main() {
  testWidgets('ShowTopBar의 뒤로·채팅 버튼은 각자 콜백을 부른다', (tester) async {
    var back = 0;
    var chat = 0;
    await _pump(
      tester,
      ShowTopBar(
        title: '소음공장 합동공연',
        backTooltip: '뒤로',
        onBack: () => back++,
        chatTooltip: '채팅',
        onChatTap: () => chat++,
      ),
    );

    await tester.tap(find.byTooltip('뒤로'));
    expect((back, chat), (1, 0));

    await tester.tap(find.byTooltip('채팅'));
    expect((back, chat), (1, 1));
  });

  testWidgets('EntryTopBar의 닫기 버튼을 누르면 onClose를 부른다', (tester) async {
    var closes = 0;
    await _pump(
      tester,
      EntryTopBar(title: '현장 입장', closeTooltip: '닫기', onClose: () => closes++),
    );

    await tester.tap(find.byTooltip('닫기'));

    expect(closes, 1);
  });
}
