import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/theme/app_theme.dart';
import 'concert_session_scope.dart';
import 'providers.dart';
import 'router.dart';
import 'routes.dart';

/// 왼쪽 위 DEV 띠를 누르는 영역 (띠가 걸친 모서리 정사각형). 화면 크기와 무관한 dev 전용 값.
const _devBannerHitSize = 56.0;

class HighfiveApp extends ConsumerWidget {
  const HighfiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'highfive',
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        // 기기의 글자 크기 설정을 따르지 않는다. 디자인 토큰 크기 그대로 보인다 (docs/design-tokens.md 글자).
        child = ConcertSessionScope(
          child: MediaQuery.withNoTextScaling(child: child!),
        );
        if (!env.isDev) return child;
        // dev 빌드는 release 모드로도 배포하므로 DEBUG 배너와 별개로 표시한다.
        // DEV 띠를 길게 누르면 공통 위젯 모음을 연다.
        return Stack(
          children: [
            Banner(
              message: 'DEV',
              location: BannerLocation.topStart,
              child: child,
            ),
            Positioned(
              top: 0,
              left: 0,
              width: _devBannerHitSize,
              height: _devBannerHitSize,
              child: GestureDetector(
                key: const ValueKey('app_devGalleryEntry'),
                behavior: HitTestBehavior.translucent,
                onLongPress: () => router.push(AppRoutes.devWidgets),
              ),
            ),
          ],
        );
      },
    );
  }
}
