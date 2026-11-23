import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/show/image_input.dart';

// 1 × 1 투명 PNG. 이미지를 고른 상태를 만들 때만 쓴다.
final _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  ),
);

ImageInput _input({ImageProvider? image, VoidCallback? onTap}) => ImageInput(
  title: '공연 포스터',
  placeholder: '포스터 이미지 추가',
  changeLabel: '사진 변경',
  image: image,
  onTap: onTap,
);

void main() {
  testWidgets('이미지가 없으면 상자를 눌러 onTap을 부르고 사진 변경 버튼은 없다', (tester) async {
    var taps = 0;
    await _pump(tester, _input(onTap: () => taps++));

    await tester.tap(find.text('포스터 이미지 추가'));

    expect(taps, 1);
    expect(find.text('사진 변경'), findsNothing);
  });

  testWidgets('이미지가 있으면 사진 변경 버튼을 보이고 누르면 onTap을 부른다', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      _input(image: MemoryImage(_transparentPng), onTap: () => taps++),
    );

    await tester.tap(find.text('사진 변경'));

    expect(taps, 1);
    expect(find.text('포스터 이미지 추가'), findsNothing);
  });

  testWidgets('onTap이 없으면 상자가 비활성으로 읽힌다', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, _input());

    expect(
      tester.getSemantics(find.text('포스터 이미지 추가')),
      isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
    );
    semantics.dispose();
  });
}
