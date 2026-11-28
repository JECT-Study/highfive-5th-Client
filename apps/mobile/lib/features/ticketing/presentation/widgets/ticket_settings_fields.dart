import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_text_area.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/ticket_settings.dart';
import '../view_models/ticket_settings_view_model.dart';

String ticketSettingsDateLabel(DateTime date) {
  String pad(int value) => value.toString().padLeft(2, '0');
  return '${date.year}.${pad(date.month)}.${pad(date.day)} '
      '${pad(date.hour)}:${pad(date.minute)}';
}

/// 입력 위젯만 조합하며 검증/저장은 ViewModel → Repository에서 실행한다.
class TicketSettingsFields extends StatelessWidget {
  const TicketSettingsFields({
    super.key,
    required this.model,
    required this.price,
    required this.capacity,
    required this.policy,
  });

  final TicketSettingsViewModel model;
  final TextEditingController price;
  final TextEditingController capacity;
  final TextEditingController policy;

  @override
  Widget build(BuildContext context) {
    final draft = model.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x6,
      children: [
        _field(
          context,
          TicketSettingsField.price,
          '티켓 가격 (1장)',
          AppTextField(
            key: const ValueKey('ticketSettings_price'),
            controller: price,
            hintText: '0',
            suffix: const Text('원'),
            keyboardType: TextInputType.number,
            invalid: model.errors.containsKey(TicketSettingsField.price),
            onChanged: (value) => model.update(draft.copyWith(price: value)),
          ),
        ),
        _field(
          context,
          TicketSettingsField.account,
          '입금 계좌',
          AppDropdown(
            key: const ValueKey('ticketSettings_account'),
            hintText: '데모 은행 · 계좌번호 · 예금주 선택',
            value: draft.account == null
                ? null
                : '${draft.account!.bank} · ${draft.account!.number}',
            onTap: () => _choose(
              context,
              title: '입금 계좌',
              label:
                  '${TicketDemoAccount.sample.bank}\n'
                  '${TicketDemoAccount.sample.number}\n'
                  '${TicketDemoAccount.sample.holder}',
              onSelected: () => model.update(
                model.draft.copyWith(account: TicketDemoAccount.sample),
              ),
            ),
          ),
        ),
        if (draft.account case final account?)
          Text(
            '예금주  ${account.holder}',
            style: context.textStyles.body1Regular,
          ),
        _field(
          context,
          TicketSettingsField.capacity,
          '판매 수량 한도',
          AppTextField(
            key: const ValueKey('ticketSettings_capacity'),
            controller: capacity,
            suffix: const Text('장'),
            keyboardType: TextInputType.number,
            invalid: model.errors.containsKey(TicketSettingsField.capacity),
            onChanged: (value) => model.update(draft.copyWith(capacity: value)),
          ),
        ),
        for (final (field, title, value, update) in [
          (
            TicketSettingsField.performanceStartsAt,
            '공연 시작',
            draft.performanceStartsAt,
            (DateTime value) =>
                model.draft.copyWith(performanceStartsAt: value),
          ),
          (
            TicketSettingsField.performanceEndsAt,
            '공연 종료',
            draft.performanceEndsAt,
            (DateTime value) => model.draft.copyWith(performanceEndsAt: value),
          ),
          (
            TicketSettingsField.registrationClosesAt,
            '신청 마감',
            draft.registrationClosesAt,
            (DateTime value) =>
                model.draft.copyWith(registrationClosesAt: value),
          ),
          (
            TicketSettingsField.refundClosesAt,
            '환불 마감',
            draft.refundClosesAt,
            (DateTime value) => model.draft.copyWith(refundClosesAt: value),
          ),
        ])
          _field(
            context,
            field,
            title,
            AppDropdown(
              key: ValueKey('ticketSettings_${field.name}'),
              value: value == null ? null : ticketSettingsDateLabel(value),
              hintText: '날짜와 시간 선택',
              onTap: () async {
                final result = await _pickDateTime(context, value);
                if (context.mounted && result != null) {
                  model.update(update(result));
                }
              },
            ),
          ),
        _field(
          context,
          TicketSettingsField.contact,
          '문의 채널',
          AppDropdown(
            key: const ValueKey('ticketSettings_contact'),
            hintText: '데모 전화번호 · 링크 선택',
            value: draft.contact?.phone,
            onTap: () => _choose(
              context,
              title: '문의 채널',
              label:
                  '${TicketDemoContact.sample.phone}\n'
                  '${TicketDemoContact.sample.link}',
              onSelected: () => model.update(
                model.draft.copyWith(contact: TicketDemoContact.sample),
              ),
            ),
          ),
        ),
        if (draft.contact case final contact?)
          Text('링크  ${contact.link}', style: context.textStyles.body1Regular),
        _field(
          context,
          TicketSettingsField.refundPolicy,
          '환불 규정',
          AppTextArea(
            key: const ValueKey('ticketSettings_refundPolicy'),
            controller: policy,
            maxLength: 1000,
            hintText: '환불 가능 기한과 규정을 입력해 주세요.',
            onChanged: (value) =>
                model.update(draft.copyWith(refundPolicy: value)),
          ),
        ),
      ],
    );
  }

  Widget _field(
    BuildContext context,
    TicketSettingsField field,
    String title,
    Widget input,
  ) => Semantics(
    label: title,
    child: AppFormSection(
      title: title,
      required: true,
      children: [
        input,
        if (model.errors[field] case final message?)
          Text(
            message,
            key: ValueKey('ticketSettings_error_${field.name}'),
            style: context.textStyles.caption1Regular.copyWith(
              color: context.colors.statusDestructive,
            ),
          ),
      ],
    ),
  );

  Future<void> _choose(
    BuildContext context, {
    required String title,
    required String label,
    required VoidCallback onSelected,
  }) async {
    final selected = await showAppBottomSheet<bool>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x4,
        children: [
          AppModalHeader(title: title),
          Text(label, style: context.textStyles.body1Regular),
          AppButton(
            key: const ValueKey('ticketSettings_chooseDemo'),
            label: '데모 값 선택하기',
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
    if (selected == true && context.mounted) onSelected();
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime? initial,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      useRootNavigator: false,
      initialDate: initial != null && initial.isAfter(now) ? initial : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      useRootNavigator: false,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
