import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_tag.dart';
import 'package:highfive/shared/widgets/onboarding/onboarding_popup.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

OnboardingPopup _popup({
  String? memberLabel,
  VoidCallback? onCopy,
  VoidCallback? onShare,
  VoidCallback? onConfirm,
}) => OnboardingPopup(
  title: '밴드가 만들어졌어요',
  message: '설명',
  codeLabel: '방 코드',
  code: 'A7K2',
  memberLabel: memberLabel,
  copyLabel: '복사',
  onCopyPressed: onCopy,
  shareLabel: '공유',
  onSharePressed: onShare,
  confirmLabel: '다음',
  onConfirmPressed: onConfirm,
);

void main() {
  testWidgets('복사·공유·다음 버튼은 각자의 콜백을 부른다', (tester) async {
    final calls = <String>[];
    await _pump(
      tester,
      _popup(
        onCopy: () => calls.add('copy'),
        onShare: () => calls.add('share'),
        onConfirm: () => calls.add('confirm'),
      ),
    );

    await tester.tap(find.widgetWithText(AppButton, '복사'));
    await tester.tap(find.widgetWithText(AppButton, '공유'));
    await tester.tap(find.widgetWithText(AppButton, '다음'));

    expect(calls, ['copy', 'share', 'confirm']);
  });

  testWidgets('memberLabel이 있을 때만 둥근 태그를 그린다', (tester) async {
    await _pump(tester, _popup());
    expect(find.byType(AppRoundTag), findsNothing);

    await _pump(tester, _popup(memberLabel: '팀원 2명'));
    expect(find.byType(AppRoundTag), findsOneWidget);
  });
}
