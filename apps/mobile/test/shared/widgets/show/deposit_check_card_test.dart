import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/show/deposit_check_card.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

DepositCheckCard _card({
  DepositCheckStatus status = DepositCheckStatus.unconfirmed,
  String? tagLabel,
  String? deadlineLabel,
  VoidCallback? onAction,
  ValueChanged<bool>? onCheckedChanged,
  bool loading = false,
}) => DepositCheckCard(
  status: status,
  name: '정우성',
  amount: '30,000원',
  details: const ['신청자 정우성', '4321'],
  tagLabel: tagLabel,
  deadlineLabel: deadlineLabel,
  actionLabel: '입금 확인',
  onAction: onAction,
  loading: loading,
  checked: false,
  onCheckedChanged: onCheckedChanged,
);

void main() {
  testWidgets('상태에 따라 버튼 중요도를 고른다', (tester) async {
    const expected = {
      DepositCheckStatus.confirmed: AppButtonVariant.weak,
      DepositCheckStatus.unconfirmed: AppButtonVariant.fill,
      DepositCheckStatus.unpaid: AppButtonVariant.danger,
      DepositCheckStatus.cancelRequested: AppButtonVariant.danger,
    };
    for (final MapEntry(key: status, value: variant) in expected.entries) {
      await _pump(tester, _card(status: status, onAction: () {}));
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).variant,
        variant,
        reason: '$status',
      );
    }
  });

  testWidgets('버튼은 onAction을, 체크박스는 바뀐 값으로 onCheckedChanged를 부른다', (
    tester,
  ) async {
    var actions = 0;
    bool? changed;
    await _pump(
      tester,
      _card(
        onAction: () => actions++,
        onCheckedChanged: (value) => changed = value,
      ),
    );

    await tester.tap(find.byType(AppButton));
    await tester.tap(find.byType(AppCheckbox));

    expect(actions, 1);
    expect(changed, isTrue);
  });

  testWidgets('요청 중이면 버튼을 눌러도 onAction을 부르지 않는다', (tester) async {
    var actions = 0;
    await _pump(tester, _card(onAction: () => actions++, loading: true));

    await tester.tap(find.byType(AppButton));

    expect(actions, 0);
  });

  testWidgets('태그와 자동 취소 안내는 값을 줄 때만 보인다', (tester) async {
    await _pump(tester, _card());
    expect(find.byType(AppTag), findsNothing);
    expect(find.byIcon(Icons.timer_outlined), findsNothing);

    await _pump(tester, _card(tagLabel: '미입금', deadlineLabel: '5시간 후 자동 취소'));
    expect(find.byType(AppTag), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
  });
}
