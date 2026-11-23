import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/show/show_action_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('Inquiry는 줄 전체를 누르면 onAction을 부르고 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      ShowActionRow(
        type: ShowActionRowType.inquiry,
        title: '새 문의 2건',
        actionLabel: '확인하기',
        onAction: () => taps++,
      ),
    );

    await tester.tap(find.byType(ShowActionRow));

    expect(taps, 1);
    expect(find.byType(AppButton), findsNothing);
    expect(
      tester.getSemantics(find.byType(ShowActionRow)),
      isSemantics(isButton: true),
    );
    semantics.dispose();
  });

  testWidgets('Link·copy는 복사 버튼을 누르면 onAction을 부른다', (tester) async {
    for (final type in [ShowActionRowType.link, ShowActionRowType.copy]) {
      var taps = 0;
      await _pump(
        tester,
        ShowActionRow(
          type: type,
          title: '관객 신청 링크',
          actionLabel: '복사',
          onAction: () => taps++,
        ),
      );

      await tester.tap(find.byType(AppButton));

      expect(taps, 1, reason: '$type');
    }
  });

  testWidgets('onAction이 없으면 복사 버튼이 비활성으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(
      tester,
      const ShowActionRow(
        type: ShowActionRowType.link,
        title: 'highfive.link/asdfa',
        actionLabel: '복사',
        onAction: null,
      ),
    );

    expect(
      tester.getSemantics(find.byType(AppButton)),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
    semantics.dispose();
  });
}
