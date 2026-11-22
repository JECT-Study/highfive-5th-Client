import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../view_models/login_view_model.dart';

/// 로그인 화면. 소셜 로그인은 로그인 API가 나오면 붙인다.
/// 지금 버튼은 임시 토큰으로 로그인한다 (`AuthService`).
class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loginViewModelProvider).isLoading;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('로그인', style: context.textStyles.title1Bold),
              const SizedBox(height: AppSpacing.x6),
              FilledButton(
                onPressed: loading
                    ? null
                    : () => ref.read(loginViewModelProvider.notifier).login(),
                child: const Text('임시 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
