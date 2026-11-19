import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/message/post_link_bar.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('띠 어디를 눌러도 onTap을 부르고 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      PostLinkBar(
        title: 'Loud Sunday 합동공연 공고',
        details: const ['11.07(토)', '서울 마포구', '장소 미정'],
        actionLabel: '공고 보기',
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.text('Loud Sunday 합동공연 공고'));
    await tester.tap(find.text('공고 보기'));

    expect(taps, 2);
    expect(
      tester.getSemantics(find.text('공고 보기')),
      isSemantics(isButton: true),
    );
    semantics.dispose();
  });
}
