import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

/// 앱 시작 시 저장된 세션을 읽는 동안 잠깐 보이는 빈 화면.
/// 읽고 나면 라우터가 로그인 또는 홈으로 보낸다.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.backgroundNormal,
      child: const SizedBox.expand(),
    );
  }
}
