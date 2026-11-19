import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_progress_bar.dart';
import 'package:highfive/shared/widgets/show/show_progress_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('모집전은 진행 막대가 없고 다음 단계부터 막대를 한 칸씩 더 채운다', (tester) async {
    final expected = {
      ShowProgressStage.beforeRecruit: null,
      ShowProgressStage.recruiting: 1,
      ShowProgressStage.ticketSales: 2,
      ShowProgressStage.showDay: 3,
    };
    for (final MapEntry(key: stage, value: current) in expected.entries) {
      await _pump(tester, ShowProgressCard(stage: stage, title: '제목'));

      final bars = tester.widgetList<AppStepProgress>(
        find.byType(AppStepProgress),
      );
      expect(bars.map((bar) => bar.current), [?current], reason: '$stage');
    }
  });

  testWidgets('버튼을 누르면 그 버튼의 onPressed만 부른다', (tester) async {
    var manage = 0;
    var share = 0;
    await _pump(
      tester,
      ShowProgressCard(
        stage: ShowProgressStage.recruiting,
        title: '3팀 확정, 1팀 더 모집 중',
        actions: [
          (label: '공고 관리', onPressed: () => manage++, icon: null),
          (label: '공고 공유', onPressed: () => share++, icon: null),
        ],
      ),
    );

    await tester.tap(find.byType(AppButton).last);

    expect((manage, share), (0, 1));
  });

  testWidgets('footer는 카드 아래에 따로 그린다', (tester) async {
    const footerKey = ValueKey('footer');
    await _pump(
      tester,
      const ShowProgressCard(
        stage: ShowProgressStage.showDay,
        title: '오늘 19:00 공연이에요',
        footer: SizedBox(key: footerKey, height: 10),
      ),
    );

    final card = find
        .descendant(
          of: find.byType(ShowProgressCard),
          matching: find.byType(DecoratedBox),
        )
        .first;
    final cardBottom = tester.getBottomLeft(card).dy;
    expect(
      tester.getTopLeft(find.byKey(footerKey)).dy,
      greaterThan(cardBottom),
    );
  });
}
