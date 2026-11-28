import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/error_view.dart';

void main() {
  testWidgets('행동 버튼을 누르면 onAction을 한 번 부른다', (tester) async {
    var actions = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ErrorView(
            message: '불러오지 못했어요. 다시 시도해 주세요.',
            actionLabel: '다시 시도',
            onAction: () => actions++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));

    expect(actions, 1);
    expect(
      tester.getSize(find.byType(AppButton)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('행동이 진행 중이면 버튼을 다시 눌러도 행동을 실행하지 않는다', (tester) async {
    var actions = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ErrorView(
            message: '불러오지 못했어요. 다시 시도해 주세요.',
            actionLabel: '다시 시도',
            loading: true,
            onAction: () => actions++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));

    expect(actions, 0);
    expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
  });
}
