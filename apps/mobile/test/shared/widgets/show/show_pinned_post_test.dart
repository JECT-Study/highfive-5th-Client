import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/show_pinned_post.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('누르면 onTap을 부르고 버튼으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(tester, ShowPinnedPost(title: '텍스트', onTap: () => taps++));

    await tester.tap(find.byType(ShowPinnedPost));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(ShowPinnedPost)),
      isSemantics(isButton: true),
    );
    semantics.dispose();
  });
}
