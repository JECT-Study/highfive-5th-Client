import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';

/// 로그인 화면. 첫 공통 예제(로그인 → 보호 화면 → 세션 복원 → 로그아웃)를 구현할 때 채운다.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Text('로그인', style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}
