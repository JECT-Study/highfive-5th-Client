import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_values.dart';
import '../view_models/concert_edit_view_model.dart';
import '../widgets/concert_date_picker.dart';
import '../widgets/concert_date_time_section.dart';

class ConcertEditView extends ConsumerWidget {
  const ConcertEditView({
    super.key,
    required this.entry,
    required this.onClose,
    required this.onSaved,
  });

  final ConcertEditEntry entry;
  final VoidCallback onClose;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(concertEditProvider(entry));
    ref.listen(concertEditProvider(entry), (previous, next) {
      if (previous?.status != next.status &&
          next.status == ConcertEditStatus.saved) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && ModalRoute.of(context)?.isCurrent != false) {
            onSaved();
          }
        });
      }
      if (previous?.failure != next.failure &&
          next.failure == ConcertEditFailureKind.missing) {
        var dismissed = false;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('공연을 찾을 수 없어요'),
            content: const Text('삭제되었거나 더 이상 볼 수 없는 공연이에요.'),
            actions: [
              TextButton(
                onPressed: () {
                  if (dismissed) return;
                  dismissed = true;
                  Navigator.of(context).pop();
                  onClose();
                },
                child: const Text('이전 화면으로'),
              ),
            ],
          ),
        );
      }
    });
    final vm = ref.read(concertEditProvider(entry).notifier);
    return _EditForm(
      key: ValueKey(state.revision),
      state: state,
      offline: entry.offline,
      onSubmit: vm.submit,
      onReload: vm.reload,
      onClose: onClose,
    );
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm({
    super.key,
    required this.state,
    required this.offline,
    required this.onSubmit,
    required this.onReload,
    required this.onClose,
  });

  final ConcertEditState state;
  final bool offline;
  final Future<void> Function(ConcertEditForm) onSubmit;
  final Future<void> Function() onReload;
  final VoidCallback onClose;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final _form = ConcertEditForm(widget.state.snapshot.values);
  late final _controllers = {
    'title': TextEditingController(text: _form.title),
    'recruitTeamCount': TextEditingController(text: _form.recruitTeamCount),
    'place': TextEditingController(text: _form.place),
    'address': TextEditingController(text: _form.address),
    'rentalFee': TextEditingController(text: _form.rentalFee),
    'startTime': TextEditingController(text: _form.startTime?.substring(0, 5)),
    'endTime': TextEditingController(text: _form.endTime?.substring(0, 5)),
  };
  late bool _timeUndecided = _form.startTime == null && _form.endTime == null;
  late String? _rememberedStart;
  late String? _rememberedEnd;
  bool _dirty = false;
  bool _leaving = false;
  bool _closing = false;
  bool _selectingDate = false;

  @override
  void initState() {
    super.initState();
    _rememberedStart = _form.startTime;
    _rememberedEnd = _form.endTime;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changed(VoidCallback update) => setState(() {
    update();
    _dirty = true;
  });

  Future<void> _date() async {
    if (_selectingDate) return;
    _selectingDate = true;
    try {
      final original = _form.performDate;
      final picked = await showConcertDateSheet(
        context,
        initialDate: original,
        initialMonth: DateTime.tryParse(original ?? ''),
        originalDate: widget.state.snapshot.values.performDate,
        today: concertBusinessDate(DateTime.now()),
      );
      if (!mounted || picked == null || picked.date == original) return;
      _changed(() => _form.performDate = picked.date);
    } finally {
      _selectingDate = false;
    }
  }

  void _time(bool start, String text) {
    final old = start ? _rememberedStart : _rememberedEnd;
    final value = old != null && old.length >= 5 && old.substring(0, 5) == text
        ? old
        : RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(text)
        ? '$text:00'
        : text;
    _changed(() {
      if (start) {
        _form.startTime = _rememberedStart = value;
      } else {
        _form.endTime = _rememberedEnd = value;
      }
    });
  }

  void _undecided(bool value) {
    FocusManager.instance.primaryFocus?.unfocus();
    _changed(() {
      _timeUndecided = value;
      _form.startTime = value ? null : (_rememberedStart ?? '');
      _form.endTime = value ? null : (_rememberedEnd ?? '');
    });
  }

  Future<bool> _discard() async {
    if (!_dirty || widget.state.status == ConcertEditStatus.saved) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('수정 중인 내용을 나갈까요?'),
            content: const Text('저장하지 않은 변경사항은 사라져요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('계속 수정'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('나가기'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    if (!await _discard() || !mounted) {
      _closing = false;
      return;
    }
    setState(() => _leaving = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted && ModalRoute.of(context)?.isCurrent != false) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final enabled = state.canEdit;
    final fields = state.fields;
    final busy =
        state.status == ConcertEditStatus.saving ||
        state.status == ConcertEditStatus.reloading;
    final options = {
      for (final genre in state.snapshot.genres) genre.code: genre.name,
      for (final code in _form.genres)
        if (!state.snapshot.genres.any((genre) => genre.code == code))
          code: '기존 장르 ($code)',
    };
    Widget section(
      String field,
      String title,
      Widget child, {
      bool required = false,
      String? hint,
    }) => AppFormSection(
      title: title,
      required: required,
      hint: hint,
      children: [
        child,
        if (fields[field] case final String error)
          Text(
            error,
            style: context.textStyles.caption1Regular.copyWith(
              color: context.colors.statusDestructive,
            ),
          ),
      ],
    );
    Widget input(
      String field,
      ValueChanged<String> update, {
      bool number = false,
    }) => Semantics(
      label: switch (field) {
        'title' => '공연 제목',
        'recruitTeamCount' => '모집 팀 수',
        'place' => '장소명',
        'address' => '주소',
        _ => '전체 대관비',
      },
      child: AppTextField(
        key: ValueKey('concertEdit_$field'),
        controller: _controllers[field],
        enabled: enabled,
        invalid: fields.containsKey(field),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        onChanged: (value) => _changed(() => update(value)),
      ),
    );
    return PopScope(
      canPop:
          _leaving ||
          state.status == ConcertEditStatus.saved ||
          (!_dirty && !busy),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || busy) return;
        await _close();
      },
      child: Scaffold(
        appBar: AppTopBar(
          title: '공연 정보 수정',
          leading: AppIconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: '닫기',
            onPressed: busy ? null : _close,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                key: const ValueKey('concertEdit_scroll'),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
                children:
                    <Widget>[
                          if (widget.offline) ...[
                            const AppNotice(
                              message: '오프라인 미리보기 · 저장은 이 화면 안에서만 반영돼요. 서버에 연결하지 않아요.',
                            ),
                            const SizedBox(height: AppSpacing.x6),
                          ],
                          if (!state.snapshot.isParticipant) ...[
                            const AppNotice(
                              message: '참여 팀 멤버만 공연 정보를 수정할 수 있어요.',
                            ),
                            const SizedBox(height: AppSpacing.x6),
                          ],
                          if (_message(state) case final String message) ...[
                            AppNotice(message: message),
                            const SizedBox(height: AppSpacing.x6),
                          ],
                          if (state.status == ConcertEditStatus.reloading) ...[
                            const LinearProgressIndicator(),
                            const SizedBox(height: AppSpacing.x6),
                          ],
                          section(
                            'title',
                            '공연 제목',
                            input('title', (v) => _form.title = v),
                            required: true,
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          section(
                            'genres',
                            '연주 장르',
                            Wrap(
                              spacing: AppSpacing.x2,
                              runSpacing: AppSpacing.x2,
                              children: [
                                for (final option in options.entries)
                                  AppChip(
                                    label: option.value,
                                    selected: _form.genres.contains(option.key),
                                    onTap: !enabled
                                        ? null
                                        : () => _changed(() {
                                            if (!_form.genres.remove(
                                              option.key,
                                            )) {
                                              _form.genres.add(option.key);
                                            }
                                          }),
                                  ),
                              ],
                            ),
                            required: true,
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          section(
                            'recruitTeamCount',
                            '모집 팀 수',
                            input(
                              'recruitTeamCount',
                              (v) => _form.recruitTeamCount = v,
                              number: true,
                            ),
                            required: true,
                            hint: '주최 팀 제외',
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          ConcertDateTimeSection(
                            date: _form.performDate,
                            onDate: enabled ? _date : null,
                            start: _controllers['startTime']!,
                            end: _controllers['endTime']!,
                            undecided: _timeUndecided,
                            enabled: enabled,
                            onUndecided: _undecided,
                            onStart: (value) => _time(true, value),
                            onEnd: (value) => _time(false, value),
                            errors: [
                              for (final name in [
                                'performDate',
                                'startTime',
                                'endTime',
                              ])
                                if (fields[name] case final String error) error,
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          section(
                            'place',
                            '장소명',
                            input('place', (v) => _form.place = v),
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          section(
                            'address',
                            '주소',
                            input('address', (v) => _form.address = v),
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          section(
                            'rentalFee',
                            '전체 대관비 (원)',
                            input(
                              'rentalFee',
                              (v) => _form.rentalFee = v,
                              number: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x6),
                          Text(
                            '기존 지역과 포스터는 그대로 유지돼요.',
                            style: context.textStyles.body1Regular,
                          ),
                          if (fields['region'] case final String error)
                            Text(error),
                          if (fields['posterImageUrl'] case final String error)
                            Text(error),
                          if (fields['version'] case final String error)
                            Text(error),
                        ]
                        .map(
                          (child) => child is ConcertDateTimeSection
                              ? child
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.x5,
                                  ),
                                  child: child,
                                ),
                        )
                        .toList(),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x5),
                child:
                    state.status == ConcertEditStatus.needsReload ||
                        state.status == ConcertEditStatus.saved
                    ? AppButton(
                        label: '최신 정보 다시 불러오기',
                        onPressed: widget.onReload,
                      )
                    : AppButton(
                        key: const ValueKey('concertEdit_save'),
                        label: widget.offline ? '미리보기 저장' : '저장',
                        loading: busy,
                        onPressed: enabled
                            ? () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                widget.onSubmit(_form);
                              }
                            : null,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _message(ConcertEditState state) {
    if (state.status == ConcertEditStatus.saved) return '수정한 내용이 저장되었어요.';
    return switch (state.failure) {
      null => null,
      ConcertEditFailureKind.invalid => '입력값을 확인하고 다시 저장해 주세요.',
      ConcertEditFailureKind.forbidden => '수정 권한이 없어요. 참여 팀 멤버인지 확인해 주세요.',
      ConcertEditFailureKind.authentication =>
        '로그인 상태가 바뀌었어요. 다시 로그인한 뒤 열어 주세요.',
      ConcertEditFailureKind.missing => '공연을 찾을 수 없어요.',
      ConcertEditFailureKind.conflict =>
        state.status == ConcertEditStatus.editing
            ? '다른 멤버의 최신 수정 내용으로 다시 채웠어요. 확인 후 수정해 주세요.'
            : '다른 멤버가 먼저 수정했어요. 최신 정보를 불러오고 있어요.',
      ConcertEditFailureKind.uncertain =>
        '저장 결과를 확인할 수 없어요. 최신 정보를 다시 불러온 뒤 확인해 주세요.',
    };
  }
}
