import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/list/show_list_item.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

const _bookmark = ValueKey('showListItem_bookmark');

void main() {
  testWidgets('줄을 누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(tester, ShowListItem(title: '오합지졸2', onTap: () => taps++));

    await tester.tap(find.text('오합지졸2'));

    expect(taps, 1);
  });

  testWidgets('찜 아이콘을 누르면 바뀔 값으로 onBookmarkChanged를 부르고 줄의 onTap은 부르지 않는다', (
    tester,
  ) async {
    var taps = 0;
    final changes = <bool>[];
    await _pump(
      tester,
      ShowListItem(
        title: '오합지졸2',
        onTap: () => taps++,
        onBookmarkChanged: changes.add,
      ),
    );

    // 아이콘 위에 누르는 영역(44)이 겹쳐 있으므로 아이콘이 보이는 자리를 누른다.
    await tester.tapAt(tester.getCenter(find.byIcon(Icons.bookmark)));

    expect(changes, [true]);
    expect(taps, 0);
  });

  testWidgets('찜 여부를 접근성 정보로 알린다', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final bookmarked in [false, true]) {
      await _pump(
        tester,
        ShowListItem(
          title: '오합지졸2',
          bookmarked: bookmarked,
          bookmarkSemanticLabel: '찜하기',
          onBookmarkChanged: (_) {},
        ),
      );
      expect(
        tester.getSemantics(find.byKey(_bookmark)),
        isSemantics(
          isButton: true,
          isToggled: bookmarked,
          hasToggledState: true,
        ),
        reason: 'bookmarked=$bookmarked',
      );
    }
    semantics.dispose();
  });

  testWidgets('onBookmarkChanged가 없으면 찜 아이콘을 눌러도 줄의 onTap만 불린다', (
    tester,
  ) async {
    var taps = 0;
    await _pump(tester, ShowListItem(title: '오합지졸2', onTap: () => taps++));

    await tester.tap(find.byIcon(Icons.bookmark));

    expect(taps, 1);
    expect(find.byKey(_bookmark), findsNothing);
  });
}
