import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_text_area.dart';
import '../../models/ticket_schedule.dart';
import '../../models/ticket_settings.dart';
import '../view_models/ticket_settings_view_model.dart';

/// Figma 2216:135970. 첫 단계 초안을 공유하고 두 번째 다음에서만 최종 저장한다.
class TicketDescriptionSection extends StatefulWidget {
  const TicketDescriptionSection({
    super.key,
    required this.model,
    required this.onSaved,
  });

  final TicketSettingsViewModel model;
  final ValueChanged<TicketSchedule> onSaved;

  @override
  State<TicketDescriptionSection> createState() =>
      _TicketDescriptionSectionState();
}

class _TicketDescriptionSectionState extends State<TicketDescriptionSection> {
  late final _introduction = TextEditingController(
    text: widget.model.draft.introduction,
  );
  late final _precautions = TextEditingController(
    text: widget.model.draft.precautions,
  );

  @override
  void dispose() {
    _introduction.dispose();
    _precautions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.model,
    builder: (context, _) {
      final model = widget.model;
      if (!model.canEdit) {
        return const AppNotice(
          key: ValueKey('ticketDescription_denied'),
          message: '데모 공연의 주최자만 입력할 수 있어요.',
        );
      }
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          key: const ValueKey('ticketDescription_form'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x6,
          children: [
            Text('공연 소개 및 유의 사항', style: context.textStyles.title2Bold),
            for (final (field, title, controller, hint) in [
              (
                TicketSettingsField.introduction,
                '공연 소개',
                _introduction,
                '예: 데모 밴드가 함께하는 합동공연이에요.',
              ),
              (
                TicketSettingsField.precautions,
                '유의 사항',
                _precautions,
                '예: 데모 공연 시작 전에 입장해 주세요.',
              ),
            ])
              AppFormSection(
                title: title,
                children: [
                  AppTextArea(
                    key: ValueKey('ticketDescription_${field.name}'),
                    controller: controller,
                    maxLength: 200,
                    hintText: hint,
                    onChanged: (value) => model.update(switch (field) {
                      TicketSettingsField.introduction => model.draft.copyWith(
                        introduction: value,
                      ),
                      _ => model.draft.copyWith(precautions: value),
                    }),
                  ),
                  if (model.errors[field] case final error?)
                    Text(
                      error,
                      key: ValueKey('ticketDescription_error_${field.name}'),
                      style: context.textStyles.caption1Regular.copyWith(
                        color: context.colors.statusDestructive,
                      ),
                    ),
                ],
              ),
            AppButton(
              key: const ValueKey('ticketDescription_save'),
              label: '다음',
              onPressed: () {
                final result = model.save();
                if (result != null) {
                  _introduction.text = result.draft.introduction;
                  _precautions.text = result.draft.precautions;
                  widget.onSaved(result.schedule);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
