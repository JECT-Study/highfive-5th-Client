import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// 하단 탭 홈 첫 화면. 공연 상태별 화면은 홈 기능 작업에서 채운다.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Text('홈', style: context.textStyles.head),
        ),
      ),
    );
  }
}
