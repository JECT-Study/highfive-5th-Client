import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../models/concert_draft.dart';
import '../../models/concert_failure.dart';
import '../providers/concert_providers.dart';
import '../view_models/concert_creation_view_model.dart';

/// 주최 밴드 문맥을 확보한 호출자가 연다. 성공 콜백은 확인된 서버 ID만 받는다.
/// 상세 화면이 구현되기 전에는 라우터가 이 ID를 이전 화면으로 반환한다.
class ConcertCreationView extends ConsumerStatefulWidget {
  const ConcertCreationView({
    super.key,
    required this.hostBand,
    required this.onCreated,
    required this.onClose,
  });

  final HostBand hostBand;
  final ValueChanged<int> onCreated;
  final VoidCallback onClose;

  @override
  ConsumerState<ConcertCreationView> createState() =>
      _ConcertCreationViewState();
}

class _ConcertCreationViewState extends ConsumerState<ConcertCreationView> {
  // 넓은 창에서 폰 폼을 읽기 좋게 유지하는 본문 폭. 디자인 확인 전 상한.
  static const _maxContentWidth = 600.0;
  final _title = TextEditingController();
  final _place = TextEditingController();
  final _address = TextEditingController();
  final _fee = TextEditingController();
  final _genres = <String>{};
  int _teams = 1;
  DateTime? _date;
  ConcertTime? _start;
  ConcertTime? _end;

  @override
  void dispose() {
    for (final controller in [_title, _place, _address, _fee]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = ref.read(concertTodayProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: _date == null || _date!.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: DateTime(9999, 12, 31),
    );
    if (mounted && date != null) setState(() => _date = date);
  }

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _start : _end;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current?.hour ?? 19,
        minute: current?.minute ?? 0,
      ),
    );
    if (!mounted || time == null) return;
    setState(() {
      final value = ConcertTime(time.hour, time.minute);
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
    });
  }

  String _timeLabel(ConcertTime? time) => time == null
      ? '선택'
      : MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: time.hour, minute: time.minute),
          alwaysUse24HourFormat: true,
        );

  @override
  Widget build(BuildContext context) {
    final provider = concertCreationProvider(widget.hostBand);
    final state = ref.watch(provider);
    final genres = ref.watch(concertGenresProvider);
    ref.listen(provider, (previous, next) {
      if (next.concertId != null && previous?.concertId != next.concertId) {
        widget.onCreated(next.concertId!);
      }
    });
    final editable = !state.locked;

    Widget errorText(String text) => Text(
      text,
      style: context.textStyles.caption1Regular.copyWith(
        color: context.colors.statusDestructive,
      ),
    );

    Widget section(
      String title,
      String field,
      List<Widget> children, {
      bool required = false,
      String? hint,
    }) => AppFormSection(
      title: title,
      required: required,
      hint: hint,
      children: [
        ...children,
        if (state.fields[field] case final error?) errorText(error),
      ],
    );

    Widget input(
      String field,
      TextEditingController controller,
      String hint, {
      bool numeric = false,
    }) => AppTextField(
      key: ValueKey('concert_$field'),
      controller: controller,
      hintText: hint,
      enabled: editable,
      invalid: state.fields.containsKey(field),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
    );

    return PopScope(
      canPop: !state.submitting,
      child: Scaffold(
        appBar: AppTopBar(
          title: '합동공연 만들기',
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '뒤로가기',
            onPressed: state.submitting ? null : widget.onClose,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ListView(
                key: const ValueKey('concert_form'),
                padding: const EdgeInsets.all(AppSpacing.x5),
                children: [
                  AppFormSection(
                    title: '주최 밴드',
                    children: [
                      Text(
                        widget.hostBand.name,
                        style: context.textStyles.title1Bold,
                      ),
                      if (state.fields['bandId'] case final error?)
                        errorText(error),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x8),
                  section('공연 제목', 'title', [
                    input('title', _title, '30자 이내로 입력해 주세요'),
                  ], required: true),
                  const SizedBox(height: AppSpacing.x6),
                  section('공연 장르', 'genres', [
                    genres.when(
                      loading: () => const Text('장르를 불러오고 있어요.'),
                      error: (_, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('장르를 불러오지 못했어요. 연결을 확인해 주세요.'),
                          AppButton(
                            key: const ValueKey('concert_genres_retry'),
                            label: '장르 다시 불러오기',
                            variant: AppButtonVariant.weak,
                            onPressed: () =>
                                ref.invalidate(concertGenresProvider),
                          ),
                        ],
                      ),
                      data: (options) => options.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('선택 가능한 장르가 없어요. 나중에 다시 확인해 주세요.'),
                                AppButton(
                                  label: '장르 다시 불러오기',
                                  variant: AppButtonVariant.weak,
                                  onPressed: () =>
                                      ref.invalidate(concertGenresProvider),
                                ),
                              ],
                            )
                          : Wrap(
                              spacing: AppSpacing.x2,
                              runSpacing: AppSpacing.x2,
                              children: [
                                for (final genre in options)
                                  AppChip(
                                    key: ValueKey(
                                      'concert_genre_${genre.code}',
                                    ),
                                    label: genre.name,
                                    selected: _genres.contains(genre.code),
                                    onTap: editable
                                        ? () => setState(() {
                                            if (!_genres.remove(genre.code)) {
                                              _genres.add(genre.code);
                                            }
                                          })
                                        : null,
                                  ),
                              ],
                            ),
                    ),
                  ], required: true),
                  const SizedBox(height: AppSpacing.x6),
                  section(
                    '모집 팀 수',
                    'recruitTeamCount',
                    [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppStepper(
                          valueLabel: '$_teams팀',
                          onDecrement: editable && _teams > 1
                              ? () => setState(() => _teams--)
                              : null,
                          onIncrement: editable && _teams < 2147483647
                              ? () => setState(() => _teams++)
                              : null,
                        ),
                      ),
                    ],
                    required: true,
                    hint: '주최 팀 제외',
                  ),
                  const SizedBox(height: AppSpacing.x6),
                  section('공연 날짜', 'performDate', [
                    AppButton(
                      key: const ValueKey('concert_date'),
                      label: _date == null
                          ? '날짜 선택하기 · 현재 미정'
                          : '${_date!.year}년 ${_date!.month}월 ${_date!.day}일',
                      variant: AppButtonVariant.weak,
                      onPressed: editable ? _pickDate : null,
                    ),
                    if (_date != null)
                      AppButton(
                        label: '날짜 미정으로 변경',
                        variant: AppButtonVariant.weak,
                        onPressed: editable
                            ? () => setState(() => _date = null)
                            : null,
                      ),
                  ]),
                  const SizedBox(height: AppSpacing.x6),
                  section('공연 시간', 'startTime', [
                    Row(
                      spacing: AppSpacing.x2,
                      children: [
                        Expanded(
                          child: AppButton(
                            key: const ValueKey('concert_startTime'),
                            label: '시작 ${_timeLabel(_start)}',
                            variant: AppButtonVariant.weak,
                            onPressed: editable
                                ? () => _pickTime(start: true)
                                : null,
                          ),
                        ),
                        Expanded(
                          child: AppButton(
                            key: const ValueKey('concert_endTime'),
                            label: '종료 ${_timeLabel(_end)}',
                            variant: AppButtonVariant.weak,
                            onPressed: editable
                                ? () => _pickTime(start: false)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (_start == null && _end == null)
                      const Text('미정 · 시작과 종료 시간을 함께 선택해 주세요.'),
                    if (_start != null || _end != null)
                      AppButton(
                        label: '시간 미정으로 변경',
                        variant: AppButtonVariant.weak,
                        onPressed: editable
                            ? () => setState(() {
                                _start = null;
                                _end = null;
                              })
                            : null,
                      ),
                    if (state.fields['endTime'] case final error?)
                      errorText(error),
                  ]),
                  const SizedBox(height: AppSpacing.x6),
                  section('장소', 'place', [
                    input('place', _place, '장소명 · 비워두면 미정'),
                  ]),
                  const SizedBox(height: AppSpacing.x6),
                  section('주소', 'address', [
                    input('address', _address, '장소 주소'),
                  ]),
                  const SizedBox(height: AppSpacing.x6),
                  section('전체 대관비', 'rentalFee', [
                    input('rentalFee', _fee, '원 · 비워두면 미정', numeric: true),
                  ]),
                  const SizedBox(height: AppSpacing.x6),
                  if (state.failure case final failure?) ...[
                    errorText(switch (failure) {
                      ConcertFailureKind.rejected =>
                        '입력 내용을 확인해 주세요. 표시된 항목을 수정해 주세요.',
                      ConcertFailureKind.forbidden =>
                        '주최 밴드의 대표자만 만들 수 있어요. 이전 화면에서 밴드를 확인해 주세요.',
                      ConcertFailureKind.authentication =>
                        '인증이 만료되었어요. 연결을 확인한 뒤 만들기를 다시 눌러 주세요.',
                      ConcertFailureKind.notSent =>
                        '서버에 연결하지 못해 보내지 않았어요. 연결을 확인한 뒤 다시 눌러 주세요.',
                      ConcertFailureKind.uncertain =>
                        '생성 결과를 확인하지 못했어요. 중복 생성을 막기 위해 다시 보내지 않아요. '
                            '운영 담당자를 통해 생성 여부를 먼저 확인해 주세요.',
                    }),
                    const SizedBox(height: AppSpacing.x4),
                  ],
                  if (state.concertId != null)
                    const Text('공연 생성이 확인되었어요. 이전 화면으로 돌아가 주세요.'),
                  AppButton(
                    key: const ValueKey('concert_submit'),
                    label: '합동공연 만들기',
                    loading: state.submitting,
                    onPressed:
                        editable && (genres.asData?.value.isNotEmpty ?? false)
                        ? () => ref
                              .read(provider.notifier)
                              .submit(
                                ConcertDraft(
                                  title: _title.text,
                                  genres: Set.of(_genres),
                                  recruitTeamCount: _teams,
                                  performDate: _date,
                                  startTime: _start,
                                  endTime: _end,
                                  place: _place.text,
                                  address: _address.text,
                                  rentalFeeText: _fee.text,
                                ),
                              )
                        : null,
                  ),
                  if (state.failure == ConcertFailureKind.forbidden ||
                      state.concertId != null)
                    AppButton(
                      key: const ValueKey('concert_forbidden_back'),
                      label: '이전 화면으로',
                      variant: AppButtonVariant.weak,
                      onPressed: widget.onClose,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
