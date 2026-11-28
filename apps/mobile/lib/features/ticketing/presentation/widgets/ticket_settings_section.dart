import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../models/ticket_role.dart';
import '../../models/ticket_schedule.dart';
import '../../models/ticket_settings.dart';
import '../view_models/ticket_settings_view_model.dart';
import 'ticket_settings_fields.dart';

/// J160 독립 섹션. 상위 페이지가 스크롤·내비게이션을 소유한다.
/// 역할/행위자/공연이 바뀌면 초안·저장소·컨트롤러를 함께 폐기한다.
class TicketSettingsSection extends StatelessWidget {
  const TicketSettingsSection({
    super.key,
    required this.role,
    required this.concert,
    required this.actorId,
    this.onSaved,
    this.viewModel,
    this.onContinue,
  });

  final TicketRole role;
  final TicketSettingsConcert concert;
  final String actorId;
  final ValueChanged<TicketSchedule>? onSaved;
  final TicketSettingsViewModel? viewModel;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final source = viewModel;
    if (source != null &&
        (source.scope !=
                (concertId: concert.id, actorId: actorId, role: role) ||
            source.concert != concert)) {
      return const AppNotice(
        key: ValueKey('ticketSettings_denied'),
        message: '현재 공연과 사용자에 맞는 설정을 다시 열어 주세요.',
      );
    }
    return _TicketSettingsForm(
      key: ValueKey((role, concert, actorId, viewModel)),
      role: role,
      concert: concert,
      actorId: actorId,
      onSaved: onSaved,
      viewModel: viewModel,
      onContinue: onContinue,
    );
  }
}

class _TicketSettingsForm extends StatefulWidget {
  const _TicketSettingsForm({
    super.key,
    required this.role,
    required this.concert,
    required this.actorId,
    required this.onSaved,
    required this.viewModel,
    required this.onContinue,
  });

  final TicketRole role;
  final TicketSettingsConcert concert;
  final String actorId;
  final ValueChanged<TicketSchedule>? onSaved;
  final TicketSettingsViewModel? viewModel;
  final VoidCallback? onContinue;

  @override
  State<_TicketSettingsForm> createState() => _TicketSettingsFormState();
}

class _TicketSettingsFormState extends State<_TicketSettingsForm> {
  late final _model =
      widget.viewModel ??
      TicketSettingsViewModel.preview(
        role: widget.role,
        concert: widget.concert,
        actorId: widget.actorId,
      );
  late final _price = TextEditingController(text: _model.draft.price);
  late final _capacity = TextEditingController(text: _model.draft.capacity);
  late final _policy = TextEditingController(text: _model.draft.refundPolicy);

  @override
  void dispose() {
    _price.dispose();
    _capacity.dispose();
    _policy.dispose();
    if (widget.viewModel == null) _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) {
      if (!_model.canEdit) {
        return const AppNotice(
          key: ValueKey('ticketSettings_denied'),
          message: '데모 공연의 주최자만 티켓 설정을 입력할 수 있어요.',
        );
      }
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x6,
          children: [
            Text('티켓 신청', style: context.textStyles.title1Bold),
            const AppNotice(message: '합성 데이터 미리보기예요. 실제 계좌·연락처는 입력할 수 없어요.'),
            _ConcertSummary(concert: widget.concert),
            TicketSettingsFields(
              model: _model,
              price: _price,
              capacity: _capacity,
              policy: _policy,
            ),
            if (_model.saved)
              const AppNotice(
                key: ValueKey('ticketSettings_saved'),
                message: '미리보기 설정을 저장했어요. 실제 신청 페이지는 발행되지 않아요.',
              ),
            AppButton(
              key: const ValueKey('ticketSettings_save'),
              label: '다음',
              onPressed: () {
                if (widget.onContinue case final next?) {
                  if (_model.validate(includeDescription: false)) next();
                  return;
                }
                final saved = _model.save();
                if (saved != null) {
                  _price.text = saved.draft.price;
                  _capacity.text = saved.draft.capacity;
                  _policy.text = saved.draft.refundPolicy;
                  widget.onSaved?.call(saved.schedule);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

class _ConcertSummary extends StatelessWidget {
  const _ConcertSummary({required this.concert});

  final TicketSettingsConcert concert;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.x2,
    children: [
      Text('공연 기본 정보', style: context.textStyles.title2SemiBold),
      Container(
        key: const ValueKey('ticketSettings_concert'),
        padding: const EdgeInsets.all(AppSpacing.x4),
        decoration: BoxDecoration(
          color: context.colors.backgroundAlternative,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.x2,
          children: [
            Text('포스터: 데모 공연', style: context.textStyles.caption1Regular),
            Text(
              '공연명  ${concert.title}',
              style: context.textStyles.body1Regular,
            ),
            Text(
              '날짜  ${ticketSettingsDateLabel(concert.startsAt)}',
              style: context.textStyles.body1Regular,
            ),
            Text(
              '장소  ${concert.venue}',
              style: context.textStyles.body1Regular,
            ),
            Text(
              '장르  ${concert.genre}',
              style: context.textStyles.body1Regular,
            ),
            Text(
              '출연  ${concert.performers}',
              style: context.textStyles.body1Regular,
            ),
          ],
        ),
      ),
    ],
  );
}
