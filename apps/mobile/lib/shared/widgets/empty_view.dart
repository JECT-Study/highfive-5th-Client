import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 보여줄 내용이 없을 때 가운데에 두는 안내 한 줄 (pr-checklist A5).
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message}) : _inline = false;

  /// 목록 섹션 안의 안내. 바깥 여백 없이 왼쪽에 두고 본문 강조 토큰을 쓴다.
  const EmptyView.inline({super.key, required this.message}) : _inline = true;

  final String message;
  final bool _inline;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _inline ? Alignment.centerLeft : Alignment.center,
      child: Padding(
        padding: _inline
            ? EdgeInsets.zero
            : const EdgeInsets.all(AppSpacing.x5),
        child: Text(
          message,
          textAlign: _inline ? TextAlign.start : TextAlign.center,
          style:
              (_inline
                      ? context.textStyles.body1SemiBold
                      : context.textStyles.body1Regular)
                  .copyWith(color: context.colors.labelAlternative),
        ),
      ),
    );
  }
}
