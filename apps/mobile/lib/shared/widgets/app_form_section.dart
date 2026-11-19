import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `FormSection`. 폼 항목 하나: 제목(+ 필수 `*`, 힌트) 아래에 입력 위젯들을 세로로 둔다.
/// Figma 설명대로 폼에만 쓴다.
class AppFormSection extends StatelessWidget {
  const AppFormSection({
    super.key,
    required this.title,
    required this.children,
    this.required = false,
    this.hint,
  });

  final String title;
  final bool required;
  final String? hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final titleStyle = textStyles.title2SemiBold.copyWith(
      color: colors.labelNormal,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppFormSectionTokens.gap,
      children: [
        Row(
          spacing: AppFormSectionTokens.gap,
          children: [
            Text(required ? '$title *' : title, style: titleStyle),
            if (hint != null)
              Flexible(
                child: Text(
                  hint!,
                  style: textStyles.caption1Regular.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
              ),
          ],
        ),
        ...children,
      ],
    );
  }
}
