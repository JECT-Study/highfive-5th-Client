import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';

/// 하단 탭 팀 모집 첫 화면. 목록·필터는 팀 모집 기능 작업에서 채운다.
class RecruitmentListView extends StatelessWidget {
  const RecruitmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x4),
          child: Text('팀 모집', style: context.textStyles.head),
        ),
      ),
    );
  }
}
