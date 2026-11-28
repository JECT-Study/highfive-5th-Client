import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 보여줄 내용이 없을 때 가운데에 두는 안내 한 줄 (pr-checklist A5).
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyles.body1Regular.copyWith(
            color: context.colors.labelAlternative,
          ),
        ),
      ),
    );
  }
}
