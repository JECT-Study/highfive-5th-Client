import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_icon.dart';
import 'package:highfive/shared/widgets/app_selection_controls.dart';
import 'package:highfive/shared/widgets/list/notification_row.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

const _unreadDot = ValueKey('notificationRow_unreadDot');

void main() {
  group('NotificationRow', () {
    testWidgets('누르면 onTap을 부른다', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        NotificationRow(
          icon: AppIcons.message,
          title: '새 문의',
          message: '공고에 문의가 왔어요.',
          time: '방금',
          onTap: () => taps++,
        ),
      );

      await tester.tap(find.byType(NotificationRow));

      expect(taps, 1);
    });

    testWidgets('안 읽은 알림에만 분홍 점을 보인다', (tester) async {
      for (final unread in [false, true]) {
        await _pump(
          tester,
          NotificationRow(
            icon: AppIcons.message,
            title: '새 문의',
            message: '공고에 문의가 왔어요.',
            time: '방금',
            unread: unread,
          ),
        );
        expect(
          find.byKey(_unreadDot),
          unread ? findsOneWidget : findsNothing,
          reason: 'unread=$unread',
        );
      }
    });
  });

  group('NotificationSettingRow', () {
    testWidgets('toggle 줄의 토글을 누르면 반대 값으로 onChanged를 부른다', (tester) async {
      final changes = <bool>[];
      await _pump(
        tester,
        NotificationSettingRow.toggle(
          title: '푸시 알림 받기',
          checked: true,
          onChanged: changes.add,
        ),
      );

      await tester.tap(find.byType(AppToggle));

      expect(changes, [false]);
    });

    testWidgets('next 줄을 누르면 onTap을 부른다', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        NotificationSettingRow.next(title: '푸시 알림 받기', onTap: () => taps++),
      );

      await tester.tap(find.byType(NotificationSettingRow));

      expect(taps, 1);
    });
  });
}
