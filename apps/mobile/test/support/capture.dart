import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// PR 캡처용. `CAPTURE_DIR=<폴더>`를 주고 위젯 테스트를 돌리면 [capture]가 화면을 PNG로 남긴다.
/// 값이 없으면(평소·CI) 아무것도 하지 않는다. 비교(golden) 테스트가 아니다.
final _captureDirectory = Platform.environment['CAPTURE_DIR'];

/// 캡처할 앱을 감싸는 경계의 키. [capturable]로 감싼다.
const _captureKey = ValueKey('test_capture');

/// 캡처할 때만 실제 글꼴(Pretendard, Material 아이콘)을 읽는다. 테스트 기본 글꼴은 네모로 그려진다.
Future<void> loadCaptureFonts() async {
  if (_captureDirectory == null) return;
  final pretendard = FontLoader('Pretendard');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    pretendard.addFont(
      rootBundle.load('assets/fonts/pretendard/Pretendard-$weight.otf'),
    );
  }
  await pretendard.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}

/// 폰 화면 크기(논리 픽셀)로 맞춘다. 테스트가 끝나면 되돌린다.
void usePhoneSize(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

/// [app]을 캡처 경계로 감싼다. 다이얼로그·바텀시트도 앱 안에 그려지므로 함께 찍힌다.
Widget capturable(Widget app) => RepaintBoundary(key: _captureKey, child: app);

Future<void> capture(WidgetTester tester, String name) async {
  final directory = _captureDirectory;
  if (directory == null) return;
  // 연속 위젯 테스트의 글꼴 캐시도 갱신한 뒤 그린다.
  await tester.runAsync(loadCaptureFonts);
  // 위젯 상태는 보존하면서 텍스트·레이어 캐시까지 다시 그려 연속 캡처의 글자 누락을 막는다.
  final reassembled = tester.binding.reassembleApplication();
  // 재조립 Future는 endOfFrame을 기다리므로 먼저 테스트 프레임을 진행한다.
  await tester.pump();
  await reassembled;
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('$directory/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}
