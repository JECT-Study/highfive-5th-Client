import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'concert_date_picker.dart';

/// 2217:123929에서 확인한 로컬 다크 토큰. 공통 테마에는 전파하지 않는다.
abstract final class ConcertDateTimeTokens {
  static const background = Color(0xFF141416);
  static const surface = Color(0xFF222125);
  static const label = Color(0xFFEAEAEB);
  static const assistive = Color(0xFF747477);
  static const disabled = Color(0xFF59595D);
  static const checkboxSize = 18.0;
}

class ConcertDateTimeSection extends StatelessWidget {
  const ConcertDateTimeSection({
    super.key,
    required this.date,
    required this.onDate,
    required this.start,
    required this.end,
    required this.undecided,
    required this.enabled,
    required this.onUndecided,
    required this.onStart,
    required this.onEnd,
    required this.errors,
  });

  final String? date;
  final VoidCallback? onDate;
  final TextEditingController start;
  final TextEditingController end;
  final bool undecided;
  final bool enabled;
  final ValueChanged<bool> onUndecided;
  final ValueChanged<String> onStart;
  final ValueChanged<String> onEnd;
  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors.copyWith(
      labelNormal: ConcertDateTimeTokens.label,
      labelAlternative: ConcertDateTimeTokens.assistive,
      labelDisable: ConcertDateTimeTokens.disabled,
      backgroundNormal: ConcertDateTimeTokens.surface,
      inverseBackground: ConcertDateTimeTokens.surface,
      inverseLabel: ConcertDateTimeTokens.label,
      interactionDisable: ConcertDateTimeTokens.surface,
      lineStrong: ConcertDateTimeTokens.surface,
    );
    final title = context.textStyles.body1SemiBold.copyWith(
      color: ConcertDateTimeTokens.label,
    );
    Widget timeInput(
      String name,
      String label,
      TextEditingController controller,
      ValueChanged<String> onChanged,
    ) => Expanded(
      child: Semantics(
        label: label,
        child: AppTextField(
          key: ValueKey('concertEdit_$name'),
          controller: controller,
          hintText: 'HH:mm',
          enabled: enabled && !undecided,
          keyboardType: TextInputType.datetime,
          onChanged: onChanged,
        ),
      ),
    );
    return Theme(
      data: theme.copyWith(extensions: [...theme.extensions.values, colors]),
      child: ColoredBox(
        color: ConcertDateTimeTokens.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('공연 날짜*', style: title),
              const SizedBox(height: AppSpacing.x1_5),
              ConcertDateInput(
                key: const ValueKey('concertEdit_date'),
                value: date,
                onTap: onDate,
              ),
              const SizedBox(height: AppSpacing.x6),
              Row(
                children: [
                  Expanded(child: Text('공연 시간', style: title)),
                  MergeSemantics(
                    child: InkWell(
                      key: const ValueKey('concertEdit_timeUndecided'),
                      onTap: enabled ? () => onUndecided(!undecided) : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: ConcertDateTimeTokens.checkboxSize,
                            height: ConcertDateTimeTokens.checkboxSize,
                            child: Checkbox(
                              value: undecided,
                              onChanged: enabled
                                  ? (value) => onUndecided(value!)
                                  : null,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(
                                color: ConcertDateTimeTokens.assistive,
                              ),
                              fillColor: WidgetStateProperty.resolveWith(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                    ? ConcertDateTimeTokens.assistive
                                    : colors.fillAlternative,
                              ),
                              checkColor: ConcertDateTimeTokens.background,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x1_5),
                          Text(
                            '아직 미정이에요',
                            style: context.textStyles.body1Regular.copyWith(
                              color: ConcertDateTimeTokens.assistive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x1_5),
              Row(
                spacing: AppSpacing.x1_5,
                children: [
                  timeInput('startTime', '공연 시작 시간', start, onStart),
                  Text(
                    '~',
                    style: context.textStyles.body1Regular.copyWith(
                      color: ConcertDateTimeTokens.assistive,
                    ),
                  ),
                  timeInput('endTime', '공연 종료 시간', end, onEnd),
                ],
              ),
              for (final error in errors)
                Text(
                  error,
                  style: context.textStyles.caption1Regular.copyWith(
                    color: colors.statusDestructive,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
