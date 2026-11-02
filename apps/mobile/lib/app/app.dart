import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/theme/app_theme.dart';
import 'providers.dart';
import 'router.dart';

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
        if (!env.isDev) return child!;
        // dev 빌드는 release 모드로도 배포하므로 DEBUG 배너와 별개로 표시한다.
        return Banner(
          message: 'DEV',
          location: BannerLocation.topStart,
          child: child,
        );
      },
    );
  }
}
