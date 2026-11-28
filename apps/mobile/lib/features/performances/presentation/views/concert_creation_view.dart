import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip_group.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/show/image_input.dart';
import '../../models/concert_creation_failure.dart';
import '../../models/concert_draft.dart';
import '../../models/concert_genre.dart';
import '../../models/host_band.dart';
import '../providers/concert_creation_providers.dart';
import '../view_models/concert_creation_view_model.dart';
import '../widgets/perform_date_sheet.dart';

/// Figma `공연열고 팀 모집`(2217:123040) 합동공연 만들기 화면.
///
/// 주최 밴드는 연 쪽(밴드 선택 시트, 나중에 밴드 프로필)이 정해 [hostBand]로 넘긴다.
/// 이 화면은 경로를 모르고, 닫기와 만든 뒤 이동은 [onClose]·[onCreated]로 라우터에 맡긴다.
///
/// 공연 포스터와 공연 장소는 서버 계약(포스터 업로드 용도, 장소 검색)이 아직 없어 시안 모양만 두고 누를 수 없다.
/// 장소는 미정, 포스터는 없음으로 만든다 (docs/api/concert-create.md).
class ConcertCreationView extends ConsumerStatefulWidget {
  const ConcertCreationView({
    super.key,
    required this.hostBand,
    required this.onClose,
    required this.onCreated,
  });

  final HostBand hostBand;
  final VoidCallback onClose;

  /// 서버가 만든 공연 ID를 받는다.
  final ValueChanged<int> onCreated;

  static const formKey = ValueKey('concertCreation_form');
  static const titleKey = ValueKey('concertCreation_title');
  static const performDateKey = ValueKey('concertCreation_performDate');
  static const rentalFeeKey = ValueKey('concertCreation_rentalFee');
  static const rentalFeeUndecidedKey = ValueKey(
    'concertCreation_rentalFeeUndecided',
  );
  static const submitKey = ValueKey('concertCreation_submit');

  @override
  ConsumerState<ConcertCreationView> createState() =>
      _ConcertCreationViewState();
}

class _ConcertCreationViewState extends ConsumerState<ConcertCreationView> {
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const _chevronSize = 14.0; // Figma: 장소 입력칸 오른쪽 화살표

  final _title = TextEditingController();
  final _performDateLabel = TextEditingController();
  final _rentalFee = TextEditingController();
  final _genres = <ConcertGenre>{};
  final _sectionKeys = {
    for (final field in ConcertDraftField.values) field: GlobalKey(),
  };
  int _recruitTeamCount = ConcertDraft.minRecruitTeamCount;
  DateTime? _performDate;

  // Figma: 처음에는 전체 대관비 "아직 미정이에요"가 체크돼 있다.
  bool _rentalFeeUndecided = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(concertCreationViewModelProvider.notifier)
          .restore(widget.hostBand);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _performDateLabel.dispose();
    _rentalFee.dispose();
    super.dispose();
  }

  void _submit() => ref
      .read(concertCreationViewModelProvider.notifier)
      .submit(
        widget.hostBand,
        ConcertDraft(
          title: _title.text,
          genres: Set.of(_genres),
          recruitTeamCount: _recruitTeamCount,
          performDate: _performDate,
          rentalFeeUndecided: _rentalFeeUndecided,
          rentalFeeText: _rentalFee.text,
        ),
      );

  Future<void> _pickPerformDate() async {
    final picked = await showPerformDateSheet(
      context,
      today: ref.read(concertTodayProvider)(),
      initialDate: _performDate,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _performDate = picked;
      _performDateLabel.text =
          '${picked.year}.${_twoDigits(picked.month)}.${_twoDigits(picked.day)}'
          ' (${_weekdays[picked.weekday - DateTime.monday]})';
    });
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  void _onStateChanged(
    ConcertCreationState? previous,
    ConcertCreationState next,
  ) {
    if (next.concertId case final concertId? when previous?.concertId == null) {
      widget.onCreated(concertId);
      return;
    }
    if (next.errors.isNotEmpty && !identical(next.errors, previous?.errors)) {
      _revealFirstError(next.errors);
    }
    if (next.failure case final failure? when previous?.failure != failure) {
      _showFailure(failure);
    }
  }

  /// 만들기가 막히면 첫 오류 칸을 화면에 보인다. 안내는 오류 위젯의 liveRegion으로 읽는다.
  void _revealFirstError(Map<ConcertDraftField, ConcertDraftError> errors) {
    final field = ConcertDraftField.values.firstWhere(errors.containsKey);
    final target = _sectionKeys[field]!.currentContext;
    if (target != null) {
      unawaited(
        Scrollable.ensureVisible(target, duration: kThemeAnimationDuration),
      );
    }
  }

  Future<void> _showFailure(ConcertCreationFailureReason reason) async {
    final (title, message) = switch (reason) {
      ConcertCreationFailureReason.unavailable => (
        '아직 실제 공연을 만들 수 없어요',
        '실서버 공연 만들기는 현재 이용할 수 없어요.',
      ),
      ConcertCreationFailureReason.invalidInput => (
        '입력한 내용을 확인해 주세요',
        '서버가 입력값을 받지 않았어요. 고친 뒤 다시 만들어 주세요.',
      ),
      ConcertCreationFailureReason.pastDate => (
        '공연 날짜를 확인해 주세요',
        '오늘이나 그 이후 날짜만 고를 수 있어요.',
      ),
      ConcertCreationFailureReason.forbidden => (
        '공연을 만들 수 없어요',
        '밴드 대표자만 공연을 만들 수 있어요.',
      ),
      ConcertCreationFailureReason.network => (
        '공연을 만들지 못했어요',
        '네트워크 상태를 확인하고 다시 시도해 주세요.',
      ),
      ConcertCreationFailureReason.rejected => (
        '공연을 만들지 못했어요',
        '잠시 후 다시 시도해 주세요.',
      ),
      ConcertCreationFailureReason.uncertain => (
        '공연이 만들어졌는지 확인하지 못했어요',
        '같은 공연이 두 번 만들어질 수 있어 이 화면에서는 다시 보내지 않아요.',
      ),
    };
    await showAppDialog(
      context,
      title: title,
      message: message,
      confirmLabel: '확인',
    );
    if (reason == ConcertCreationFailureReason.forbidden && mounted) {
      widget.onClose();
    }
  }

  static String _errorMessage(
    ConcertDraftField field,
    ConcertDraftError error,
  ) => switch ((field, error)) {
    (ConcertDraftField.title, ConcertDraftError.tooLong) =>
      '공연 제목은 ${ConcertDraft.titleMaxLength}자까지 입력할 수 있어요.',
    (ConcertDraftField.title, _) => '공연 제목을 입력해 주세요.',
    (ConcertDraftField.genres, _) => '연주 장르를 하나 이상 골라 주세요.',
    (ConcertDraftField.performDate, ConcertDraftError.pastDate) =>
      '오늘이나 그 이후 날짜를 골라 주세요.',
    (ConcertDraftField.performDate, _) => '공연 날짜를 골라 주세요.',
    (ConcertDraftField.recruitTeamCount, _) =>
      '모집 팀 수는 ${ConcertDraft.minRecruitTeamCount}팀 이상이어야 해요.',
    (ConcertDraftField.rentalFee, ConcertDraftError.invalidAmount) =>
      '대관비는 2,147,483,647원까지 숫자로 입력해 주세요.',
    (ConcertDraftField.rentalFee, _) => '대관비를 입력하거나 아직 미정이에요를 골라 주세요.',
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(concertCreationViewModelProvider);
    ref.listen(concertCreationViewModelProvider, _onStateChanged);
    final colors = context.colors;
    final textStyles = context.textStyles;
    final editable = !state.locked;
    final errors = state.errors;

    Widget? errorText(ConcertDraftField field) => switch (errors[field]) {
      final error? => Semantics(
        liveRegion: true,
        child: Text(
          _errorMessage(field, error),
          style: textStyles.caption1Regular.copyWith(
            color: colors.statusDestructive,
          ),
        ),
      ),
      null => null,
    };

    // Figma: 항목마다 위아래 12, 좌우 20. 구역 제목(필수·선택 정보)은 아래 6.
    Widget item(
      Widget child, {
      ConcertDraftField? field,
      double bottom = AppSpacing.x3,
    }) => KeyedSubtree(
      key: field == null ? null : _sectionKeys[field],
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.x5,
          AppSpacing.x3,
          AppSpacing.x5,
          bottom,
        ),
        child: child,
      ),
    );
    Widget group(String title, {required double top}) => Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.x5,
        top,
        AppSpacing.x5,
        AppSpacing.x1_5,
      ),
      child: Text(
        title,
        style: textStyles.title2SemiBold.copyWith(color: colors.labelNormal),
      ),
    );

    return PopScope(
      canPop: !state.submitting,
      child: Scaffold(
        backgroundColor: colors.backgroundNormal,
        appBar: AppTopBar(
          title: '합동 공연 만들기',
          leading: AppIconButton(
            icon: const AppIcon(AppIcons.close),
            tooltip: '닫기',
            onPressed: state.submitting ? null : widget.onClose,
          ),
        ),
        // 폼이 짧아 한 번에 그린다. 첫 오류 칸으로 옮길 때 화면 밖 칸도 찾을 수 있다.
        body: SingleChildScrollView(
          key: ConcertCreationView.formKey,
          // iOS 숫자 키패드에는 닫기 키가 없고 하단 버튼이 키보드에 가려진다. 폼을 끌면 키보드를 닫는다.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              group('필수 정보', top: AppSpacing.x1_5),
              item(
                field: ConcertDraftField.title,
                AppFormSection(
                  title: '공연 제목',
                  children: [
                    AppTextField(
                      key: ConcertCreationView.titleKey,
                      controller: _title,
                      hintText: '예: 소음공장 합동공연',
                      enabled: editable,
                      invalid: errors.containsKey(ConcertDraftField.title),
                      textInputAction: TextInputAction.done,
                    ),
                    ?errorText(ConcertDraftField.title),
                  ],
                ),
              ),
              item(
                field: ConcertDraftField.genres,
                AppFormSection(
                  title: '연주 장르',
                  children: [
                    AppChipGroup(
                      labels: [
                        for (final genre in ConcertGenre.values) genre.label,
                      ],
                      selectedIndexes: {
                        for (final genre in _genres) genre.index,
                      },
                      onTap: editable
                          ? (index) => setState(() {
                              final genre = ConcertGenre.values[index];
                              if (!_genres.remove(genre)) _genres.add(genre);
                            })
                          : null,
                    ),
                    ?errorText(ConcertDraftField.genres),
                  ],
                ),
              ),
              item(
                field: ConcertDraftField.performDate,
                AppFormSection(
                  title: '공연 날짜',
                  children: [
                    AppTextField(
                      key: ConcertCreationView.performDateKey,
                      controller: _performDateLabel,
                      hintText: '공연 날짜를 골라 주세요',
                      readOnly: true,
                      onTap: editable ? _pickPerformDate : null,
                      enabled: editable,
                      invalid: errors.containsKey(
                        ConcertDraftField.performDate,
                      ),
                    ),
                    ?errorText(ConcertDraftField.performDate),
                  ],
                ),
              ),
              // Figma `InputCount`: 위 12, 아래 32.
              item(
                field: ConcertDraftField.recruitTeamCount,
                bottom: AppSpacing.x8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.x2,
                  children: [
                    Row(
                      spacing: AppSpacing.x2_5,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: AppSpacing.x1,
                            children: [
                              Text(
                                '모집 팀 수',
                                style: textStyles.body1Medium.copyWith(
                                  color: colors.labelNormal,
                                ),
                              ),
                              Text(
                                '우리 팀 제외',
                                style: textStyles.caption1Regular.copyWith(
                                  color: colors.labelAlternative,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppStepper(
                          valueLabel: '$_recruitTeamCount팀',
                          onDecrement:
                              editable &&
                                  _recruitTeamCount >
                                      ConcertDraft.minRecruitTeamCount
                              ? () => setState(() => _recruitTeamCount--)
                              : null,
                          onIncrement: editable
                              ? () => setState(() => _recruitTeamCount++)
                              : null,
                        ),
                      ],
                    ),
                    ?errorText(ConcertDraftField.recruitTeamCount),
                  ],
                ),
              ),
              const AppSectionDivider(),
              group('선택 정보', top: AppSpacing.x6),
              item(
                const ImageInput(
                  title: '공연 포스터',
                  placeholder: '포스터 이미지 추가',
                  changeLabel: '사진 변경',
                  helperText: '모집 공고와 공연페이지의 대표 이미지로 보여요',
                  // 포스터 업로드 용도(purpose)가 서버에 아직 없다 (USER_PROFILE만 있음).
                  onTap: null,
                ),
              ),
              item(
                _UndecidedSection(
                  title: '공연 장소',
                  undecided: true,
                  // 장소 검색 계약이 아직 없어 장소는 미정으로만 만든다.
                  onUndecidedChanged: null,
                  child: AppTextField(
                    readOnly: true,
                    enabled: false,
                    suffix: Icon(
                      Icons.chevron_right,
                      size: _chevronSize,
                      color: colors.labelAssistive,
                    ),
                  ),
                ),
              ),
              item(
                field: ConcertDraftField.rentalFee,
                _UndecidedSection(
                  title: '전체 대관비',
                  checkboxKey: ConcertCreationView.rentalFeeUndecidedKey,
                  undecided: _rentalFeeUndecided,
                  onUndecidedChanged: editable
                      ? (undecided) =>
                            setState(() => _rentalFeeUndecided = undecided)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.x2,
                    children: [
                      AppTextField(
                        key: ConcertCreationView.rentalFeeKey,
                        controller: _rentalFee,
                        hintText: '숫자만 입력 (원)',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        enabled: editable && !_rentalFeeUndecided,
                        invalid:
                            !_rentalFeeUndecided &&
                            errors.containsKey(ConcertDraftField.rentalFee),
                      ),
                      ?(_rentalFeeUndecided
                          ? null
                          : errorText(ConcertDraftField.rentalFee)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x5,
              AppSpacing.x2_5,
              AppSpacing.x5,
              AppSpacing.x2_5,
            ),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                key: ConcertCreationView.submitKey,
                label: '공연 만들기',
                loading: state.submitting,
                onPressed: state.locked ? null : _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 제목 오른쪽에 "아직 미정이에요" 체크박스가 붙은 폼 항목 (Figma 공연 장소·전체 대관비).
class _UndecidedSection extends StatelessWidget {
  const _UndecidedSection({
    required this.title,
    required this.undecided,
    required this.onUndecidedChanged,
    required this.child,
    this.checkboxKey,
  });

  final String title;
  final bool undecided;
  final ValueChanged<bool>? onUndecidedChanged;
  final Widget child;
  final Key? checkboxKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final onChanged = onUndecidedChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x2,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textStyles.title2SemiBold.copyWith(
                  color: colors.labelNormal,
                ),
              ),
            ),
            AppCheckbox(
              key: checkboxKey,
              checked: undecided,
              onChanged: onChanged,
              semanticLabel: '$title 아직 미정이에요',
            ),
            // 글자를 눌러도 체크박스가 바뀐다. 읽기는 체크박스 이름으로 한 번만 한다.
            ExcludeSemantics(
              child: GestureDetector(
                onTap: onChanged == null ? null : () => onChanged(!undecided),
                child: Text(
                  '아직 미정이에요',
                  style: textStyles.body1Regular.copyWith(
                    color: colors.labelAlternative,
                  ),
                ),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
