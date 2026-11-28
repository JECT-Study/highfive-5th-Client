import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// 하단 탭 마이페이지 첫 화면. 프로필·내 활동은 마이페이지 기능 작업에서 채운다.
///
/// 로그아웃은 세션(auth 기능)을 바꾸는 일이라 이 화면이 직접 하지 않고,
/// 라우터가 [onSignOut]으로 연결한다 (다른 기능의 presentation을 import하지 않는다).
class MyPageView extends StatelessWidget {
  const MyPageView({super.key, required this.onSignOut, this.activity});

  final VoidCallback onSignOut;

  /// '내 활동'에 들어갈 다른 기능의 섹션 (예: 내 공연). 라우터가 넣는다.
  final Widget? activity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('마이페이지', style: context.textStyles.head),
              const SizedBox(height: AppSpacing.x6),
              OutlinedButton(onPressed: onSignOut, child: const Text('로그아웃')),
              if (activity case final activity?) ...[
                const SizedBox(height: AppSpacing.x6),
                SizedBox(width: double.infinity, child: activity),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
