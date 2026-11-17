import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// 하단 탭 마이페이지 첫 화면. 프로필·내 활동은 마이페이지 기능 작업에서 채운다.
class MyPageView extends StatelessWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Text('마이페이지', style: context.textStyles.head),
        ),
      ),
    );
  }
}
