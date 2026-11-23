import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_confirm_popup.dart';

/// 버튼을 눌러 팝업을 띄우고, 닫힐 때 받은 값을 [onResult]로 넘긴다.
Future<void> _open(
  WidgetTester tester, {
  required void Function(bool) onResult,
  String? cancelLabel = '취소',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => onResult(
              await showShowConfirmPopup(
                context,
                title: '공연을 삭제할까요?',
                cancelLabel: cancelLabel,
                confirmLabel: '삭제하기',
                destructive: true,
              ),
            ),
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('확인을 누르면 true, 취소를 누르면 false를 돌려준다', (tester) async {
    bool? result;
    await _open(tester, onResult: (value) => result = value);
    await tester.tap(find.text('삭제하기'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await _open(tester, onResult: (value) => result = value);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('cancelLabel이 없으면 확인 버튼 하나만 보인다', (tester) async {
    await _open(tester, onResult: (_) {}, cancelLabel: null);

    expect(find.text('삭제하기'), findsOneWidget);
    expect(find.text('취소'), findsNothing);
  });
}
