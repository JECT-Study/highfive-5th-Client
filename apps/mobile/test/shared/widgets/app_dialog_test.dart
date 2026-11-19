import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_dialog.dart';

/// 버튼을 누르면 다이얼로그를 띄우고, 돌려받은 값을 [onResult]로 넘긴다.
Future<void> _pumpLauncher(WidgetTester tester, ValueChanged<bool> onResult) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => onResult(
                await showAppDialog(
                  context,
                  title: '공고를 삭제할까요?',
                  confirmLabel: '삭제',
                  cancelLabel: '취소',
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('확인을 누르면 true를 돌려준다', (tester) async {
    bool? result;
    await _pumpLauncher(tester, (v) => result = v);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(AppDialog), findsNothing);
  });

  testWidgets('취소를 누르거나 바깥을 누르면 false를 돌려준다', (tester) async {
    bool? result;
    await _pumpLauncher(tester, (v) => result = v);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    result = null;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });
}
