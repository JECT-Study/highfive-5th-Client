import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_form_section.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/qr/qr_list_card.dart';
import '../../../../shared/widgets/show/image_input.dart';
import '../../../../shared/widgets/show/show_confirm_popup.dart';
import '../../models/concert_detail.dart';
import '../../models/concert_edit_failure.dart';
import '../../models/concert_edit_form.dart';
import '../../models/concert_edit_genres.dart';
import '../../models/concert_update.dart';
import '../providers/concert_detail_providers.dart';
import '../providers/concert_edit_providers.dart';
import '../view_models/concert_edit_view_model.dart';
import '../widgets/concert_date_sheet.dart';

/// 다른 경로에 가려진 동안 끝난 저장 결과를 복귀 시 처리한다.
final concertEditRouteObserver = RouteObserver<ModalRoute<Object?>>();

/// 공연 기본 정보 수정 (Figma `공연정보수정` 2217:123929, 확인 팝업 2217:123996, 나가기 팝업 2217:124003).
///
/// 공용 [concertDetailProvider]의 상세(version·권한 포함)로 채운다. 공연 페이지가 이미 읽었으면 같은 값을
/// 그대로 쓰고, 경로로 바로 열면 경로의 공연 ID로 읽는다. 저장 성공 후 상세 갱신은 ViewModel이 한다.
class ConcertEditView extends ConsumerStatefulWidget {
  const ConcertEditView({
    super.key,
    required this.concertId,
    required this.onClose,
    required this.onSaved,
  });

  final int concertId;

  /// 저장하지 않고 닫는다 (X·뒤로 가기·나가기, 공연 없음·권한 없음 안내 뒤).
  final VoidCallback onClose;

  /// 저장을 마쳤다.
  final VoidCallback onSaved;

  @override
  ConsumerState<ConcertEditView> createState() => _ConcertEditViewState();
}

class _ConcertEditViewState extends ConsumerState<ConcertEditView>
    with RouteAware {
  ModalRoute<Object?>? _route;
  ConcertEditState? _pending;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of<Object?>(context);
    if (route == _route) return;
    concertEditRouteObserver.unsubscribe(this);
    _route = route;
    if (route != null) concertEditRouteObserver.subscribe(this, route);
  }

  @override
  void didUpdateWidget(ConcertEditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.concertId != widget.concertId) _pending = null;
  }

  @override
  void dispose() {
    concertEditRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _scheduleOutcome();

  void _scheduleOutcome() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted || !(_route?.isCurrent ?? true)) return;
      final pending = _pending;
      _pending = null;
      if (pending?.status == ConcertEditStatus.saved) {
        widget.onSaved();
      } else if (pending?.failure case final failure?) {
        _showFailure(context, failure);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final concertId = widget.concertId;
    final onClose = widget.onClose;
    ref.listen(concertEditProvider(concertId), (previous, next) {
      if (next.status == ConcertEditStatus.saved) {
        if (previous?.status != ConcertEditStatus.saved) {
          _pending = next;
          _scheduleOutcome();
        }
        return;
      }
      final failure = next.failure;
      if (failure != null && !identical(failure, previous?.failure)) {
        _pending = next;
        _scheduleOutcome();
      }
    });
    return ref
        .watch(concertDetailProvider(concertId))
        .when(
          skipLoadingOnRefresh: false,
          // 다른 멤버의 수정으로 version이 바뀌면 입력을 최신 상세로 새로 채운다.
          data: (detail) => _EditForm(
            key: ValueKey((detail.concertId, detail.version)),
            detail: detail,
            onClose: onClose,
          ),
          error: (error, _) => _Frame(
            onClose: onClose,
            interceptBack: true,
            body: _LoadError(
              error: error,
              onRetry: () => ref.invalidate(concertDetailProvider(concertId)),
              onClose: onClose,
            ),
          ),
          loading: () => _Frame(
            onClose: onClose,
            interceptBack: true,
            body: const Center(child: CircularProgressIndicator()),
          ),
        );
  }

  /// 입력칸에 보일 수 없는 실패를 알린다. 공연이 없거나 권한이 없으면 안내 뒤 이전 화면으로 간다.
  void _showFailure(BuildContext context, ConcertEditFailure failure) {
    final notice = switch (failure.reason) {
      // 입력칸 아래에 보인다 (_EditForm).
      ConcertEditFailureReason.invalid when failure.issues.isNotEmpty => null,
      ConcertEditFailureReason.invalid => (
        title: '입력한 내용을 저장하지 못했어요',
        message: '입력값을 확인하고 다시 시도해 주세요.',
        leave: false,
      ),
      ConcertEditFailureReason.conflict => (
        title: '다른 멤버가 먼저 수정했어요',
        message: '최신 공연 정보를 다시 불러올게요. 확인한 뒤 다시 수정해 주세요.',
        leave: false,
      ),
      ConcertEditFailureReason.missing => (
        title: '공연을 찾을 수 없어요',
        message: '삭제되었거나 볼 수 없는 공연이에요.',
        leave: true,
      ),
      ConcertEditFailureReason.forbidden => (
        title: '공연 정보를 수정할 수 없어요',
        message: '참여 팀 멤버만 공연 정보를 수정할 수 있어요.',
        leave: true,
      ),
      ConcertEditFailureReason.unconfirmed => (
        title: '저장 결과를 확인하지 못했어요',
        message: '네트워크 상태를 확인한 뒤 저장 결과를 다시 확인해 주세요.',
        leave: false,
      ),
      ConcertEditFailureReason.failed => (
        title: '공연 정보를 저장하지 못했어요',
        message: '잠시 후 다시 시도해 주세요.',
        leave: false,
      ),
    };
    if (notice == null) return;
    showAppDialog(
      context,
      title: notice.title,
      message: notice.message,
      confirmLabel: notice.leave ? '이전 화면으로' : '확인',
    ).then((_) {
      if (notice.leave && context.mounted) {
        _whenCurrent(context, widget.onClose);
      }
    });
  }
}

/// 늦게 끝난 저장·안내가 이 화면 위에 쌓인 다른 화면을 닫지 않게, 이 화면이 맨 위일 때만 움직인다.
void _whenCurrent(BuildContext context, VoidCallback action) {
  if (context.mounted && (ModalRoute.of(context)?.isCurrent ?? true)) action();
}

/// 상단 바(X·제목)와 본문, 아래 고정 영역.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.onClose,
    required this.body,
    this.bottom,
    this.interceptBack = false,
  });

  final VoidCallback? onClose;
  final Widget body;
  final Widget? bottom;
  final bool interceptBack;

  @override
  Widget build(BuildContext context) {
    final bottom = this.bottom;
    return PopScope(
      canPop: !interceptBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && interceptBack) onClose?.call();
      },
      child: Scaffold(
        backgroundColor: context.colors.backgroundNormal,
        appBar: AppTopBar(
          title: '공연 정보 수정',
          leading: AppIconButton(
            key: const ValueKey('concertEdit_close'),
            icon: const AppIcon(AppIcons.close),
            tooltip: '닫기',
            onPressed: onClose,
          ),
        ),
        body: Column(
          children: [
            Expanded(child: body),
            if (bottom != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.x5,
                    AppSpacing.x3,
                    AppSpacing.x5,
                    AppSpacing.x5,
                  ),
                  child: bottom,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 상세를 읽지 못했을 때. 공연이 없거나 참여 팀 멤버가 아니면 다시 시도해도 같아서 이전 화면으로 보낸다.
class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.error,
    required this.onRetry,
    required this.onClose,
  });

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final (title, message, action, onPressed) = switch (error) {
      ApiException(code: 'CONCERT_001') => (
        '공연을 찾을 수 없어요',
        '삭제되었거나 볼 수 없는 공연이에요.',
        '이전 화면으로',
        onClose,
      ),
      ApiException(code: 'AUTH_005') => (
        '공연 정보를 수정할 수 없어요',
        '참여 팀 멤버만 공연 정보를 수정할 수 있어요.',
        '이전 화면으로',
        onClose,
      ),
      _ => ('공연 정보를 불러오지 못했어요', '네트워크 상태를 확인하고 다시 시도해 주세요.', '다시 시도', onRetry),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.x2,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: textStyles.title1Bold.copyWith(color: colors.labelNormal),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyles.body1Regular.copyWith(
                color: colors.labelAlternative,
              ),
            ),
            const SizedBox(height: AppSpacing.x3),
            AppButton(
              key: const ValueKey('concertEdit_loadAction'),
              label: action,
              size: AppButtonSize.medium,
              variant: AppButtonVariant.weak,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({super.key, required this.detail, required this.onClose});

  final ConcertDetail detail;
  final VoidCallback onClose;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late final _form = ConcertEditForm(widget.detail);
  late final _title = TextEditingController(text: _form.title);
  late final _date = TextEditingController(text: _dateText);
  late final _start = TextEditingController(text: _form.startTime);
  late final _end = TextEditingController(text: _form.endTime);
  late final _place = TextEditingController(text: _form.place);
  late final _address = TextEditingController(text: _form.address);
  late final _rentalFee = TextEditingController(text: _commas(_form.rentalFee));
  final _rentalFeeFocus = FocusNode();

  /// 고를 수 있는 장르. 목록에 없는 기존 장르도 지우지 않도록 뒤에 붙인다.
  late final _genreOptions = [
    ...concertGenres,
    for (final code in widget.detail.genres)
      if (!concertGenres.any((genre) => genre.code == code))
        (code: code, name: concertGenreName(code)),
  ];

  var _issues = <ConcertEditField, ConcertEditIssue>{};
  var _serverReasons = <ConcertEditField, String>{};

  /// 확인 팝업이나 달력이 열려 있다. 연타로 두 번 열지 않는다.
  bool _busy = false;

  /// 나가기로 정했다. 뒤로 가기를 더 막지 않는다.
  bool _leaving = false;

  int get _concertId => widget.detail.concertId;

  String get _dateText => switch (_form.performDate) {
    final date? => concertDateLabel(date),
    null => '',
  };

  @override
  void initState() {
    super.initState();
    _rentalFeeFocus.addListener(_formatRentalFee);
  }

  @override
  void dispose() {
    _rentalFeeFocus.removeListener(_formatRentalFee);
    _rentalFeeFocus.dispose();
    for (final controller in [
      _title,
      _date,
      _start,
      _end,
      _place,
      _address,
      _rentalFee,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 값을 바꾸고, 그 칸에 떠 있던 오류를 지운다.
  void _edit(ConcertEditField field, VoidCallback change) => setState(() {
    change();
    _issues.remove(field);
    _serverReasons.remove(field);
  });

  Future<void> _pickDate() async {
    if (_busy) return;
    _busy = true;
    final picked = await showConcertDateSheet(
      context,
      initialDate: _form.performDate,
      originalDate: widget.detail.performDate,
      today: ref.read(concertEditTodayProvider)(),
    );
    _busy = false;
    if (picked == null || !mounted) return;
    _edit(ConcertEditField.performDate, () {
      _form.performDate = picked;
      _date.text = _dateText;
    });
  }

  /// 입력 중에는 숫자 원문, 포커스를 잃으면 천 단위 쉼표를 보인다.
  void _formatRentalFee() {
    final text = _rentalFee.text;
    if (!RegExp(r'^(\d*|\d{1,3}(,\d{3})+)$').hasMatch(text)) return;
    final digits = text.replaceAll(',', '');
    final formatted = _rentalFeeFocus.hasFocus ? digits : _commas(digits);
    if (formatted == text) return;
    final cursor = _rentalFeeFocus.hasFocus
        ? text
              .substring(
                0,
                _rentalFee.selection.extentOffset.clamp(0, text.length),
              )
              .replaceAll(',', '')
              .length
        : formatted.length;
    _rentalFee.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  /// 소수점·부호는 지우지 않는다. 정상 천 단위 쉼표만 숫자 원문으로 해석한다.
  void _changeRentalFee(String text) {
    if (!RegExp(r'^(\d*|\d{1,3}(,\d{3})+)$').hasMatch(text)) {
      _edit(ConcertEditField.rentalFee, () => _form.rentalFee = text);
      return;
    }
    final digits = text.replaceAll(',', '');
    final formatted = _rentalFeeFocus.hasFocus ? digits : _commas(digits);
    if (formatted != text) {
      _rentalFee.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    _edit(ConcertEditField.rentalFee, () => _form.rentalFee = digits);
  }

  /// 미정으로 바꾸면 입력칸을 끄되 적어 둔 값은 남겨, 해제하면 그대로 돌아온다.
  void _undecided(ConcertEditField field, bool value) {
    FocusManager.instance.primaryFocus?.unfocus();
    _edit(field, () {
      switch (field) {
        case ConcertEditField.time:
          _form.timeUndecided = value;
        case ConcertEditField.place:
          _form.placeUndecided = value;
          _issues.remove(ConcertEditField.address);
          _serverReasons.remove(ConcertEditField.address);
        case ConcertEditField.rentalFee:
          _form.rentalFeeUndecided = value;
        case _:
          break;
      }
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (ref.read(concertEditProvider(_concertId)).status ==
        ConcertEditStatus.unconfirmed) {
      await ref.read(concertEditProvider(_concertId).notifier).recheck();
      return;
    }
    final issues = _form.validate(today: ref.read(concertEditTodayProvider)());
    setState(() {
      _issues = issues;
      _serverReasons = {};
    });
    if (issues.isNotEmpty) return;
    final changes = _form.changedFields();
    // 공백만 지운 경우처럼 실제로 바뀐 값이 없으면 보낼 것이 없다.
    if (changes.isEmpty) return _leave();
    final before = ConcertUpdate.fromDetail(widget.detail);
    final update = _form.toUpdate();
    _busy = true;
    final confirmed = await showShowConfirmPopup(
      context,
      title: '공연 정보를 수정할까요?',
      message: '공연 정보와 모집 공고에 반영돼요.',
      details: [for (final field in changes) _changeRow(field, before, update)],
      warning: '티켓 신청 페이지에는 반영되지 않아요.',
      cancelLabel: '취소',
      confirmLabel: '수정하기',
    );
    _busy = false;
    if (!confirmed || !mounted) return;
    await ref.read(concertEditProvider(_concertId).notifier).save(update);
  }

  Future<void> _close() async {
    if (_busy) return;
    final unresolved =
        ref.read(concertEditProvider(_concertId)).status ==
        ConcertEditStatus.unconfirmed;
    if (unresolved || _form.isDirty) {
      _busy = true;
      final leave = await showShowConfirmPopup(
        context,
        title: unresolved ? '저장 결과 확인을 그만할까요?' : '수정을 그만할까요?',
        message: unresolved
            ? '저장 결과를 아직 확인하지 못했어요. 화면을 나가도 저장이 완료될 수 있어요.'
            : '지금까지 수정한 내용은 저장되지 않아요.',
        cancelLabel: unresolved ? '계속 확인' : '계속 수정',
        confirmLabel: '나가기',
      );
      _busy = false;
      if (!leave || !mounted) return;
    }
    _leave();
  }

  void _leave() {
    setState(() => _leaving = true);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(concertEditProvider(_concertId), (previous, next) {
      final failure = next.failure;
      if (failure == null ||
          identical(failure, previous?.failure) ||
          failure.reason != ConcertEditFailureReason.invalid) {
        return;
      }
      setState(() {
        _issues = Map.of(failure.issues);
        _serverReasons = Map.of(failure.serverReasons);
      });
    });
    final status = ref.watch(concertEditProvider(_concertId)).status;
    // 저장 중·저장 후에는 입력과 닫기를 막는다. 닫으면 저장 결과를 화면에 반영할 수 없다.
    final locked = status != ConcertEditStatus.editing;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final detail = widget.detail;
    final canChangeTeams = !locked && detail.myPermissions.isHostLeader;

    final sections = <Widget>[
      const AppNotice(
        message: '수정한 공연 정보는 모집 공고에도 반영돼요. 티켓 신청 페이지에는 반영되지 않아요.',
      ),
      ImageInput(
        title: '공연 포스터',
        placeholder: '포스터 이미지',
        changeLabel: '사진 변경',
        helperText: '모집 공고와 공연페이지의 대표 이미지로 보여요',
        image: switch (detail.posterImageUrl) {
          final url? => NetworkImage(url),
          null => null,
        },
        // 포스터 업로드 용도가 서버에 아직 없다 (presigned URL purpose는 USER_PROFILE만).
        // 기존 포스터는 [ConcertUpdate.posterImageUrl]로 그대로 보낸다.
        onTap: null,
      ),
      AppFormSection(
        title: '공연 제목',
        required: true,
        children: [
          AppTextField(
            key: const ValueKey('concertEdit_title'),
            controller: _title,
            enabled: !locked,
            invalid: _issues.containsKey(ConcertEditField.title),
            hintText: '공연 제목을 입력해 주세요',
            onChanged: (value) =>
                _edit(ConcertEditField.title, () => _form.title = value),
          ),
          ?_error(ConcertEditField.title),
        ],
      ),
      AppFormSection(
        title: '연주 장르',
        required: true,
        children: [
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              for (final genre in _genreOptions)
                AppChip(
                  key: ValueKey('concertEdit_genre_${genre.code}'),
                  label: genre.name,
                  selected: _form.genres.contains(genre.code),
                  onTap: locked
                      ? null
                      : () => _edit(ConcertEditField.genres, () {
                          if (!_form.genres.remove(genre.code)) {
                            _form.genres.add(genre.code);
                          }
                        }),
                ),
            ],
          ),
          ?_error(ConcertEditField.genres),
        ],
      ),
      AppFormSection(
        title: '공연 날짜',
        required: true,
        children: [
          AppTextField(
            key: const ValueKey('concertEdit_performDate'),
            controller: _date,
            readOnly: true,
            enabled: !locked,
            invalid: _issues.containsKey(ConcertEditField.performDate),
            hintText: '날짜를 골라 주세요',
            onTap: _pickDate,
            suffix: Icon(
              Icons.calendar_today_outlined,
              color: colors.labelAlternative,
            ),
          ),
          ?_error(ConcertEditField.performDate),
        ],
      ),
      _UndecidedSection(
        title: '공연 시간',
        undecided: _form.timeUndecided,
        onUndecided: locked
            ? null
            : (value) => _undecided(ConcertEditField.time, value),
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  key: const ValueKey('concertEdit_startTime'),
                  controller: _start,
                  enabled: !locked && !_form.timeUndecided,
                  invalid: _issues.containsKey(ConcertEditField.time),
                  hintText: '00:00',
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) => _edit(
                    ConcertEditField.time,
                    () => _form.startTime = value,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x1_5,
                ),
                child: Text(
                  '~',
                  style: textStyles.body1Regular.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
              ),
              Expanded(
                child: AppTextField(
                  key: const ValueKey('concertEdit_endTime'),
                  controller: _end,
                  enabled: !locked && !_form.timeUndecided,
                  invalid: _issues.containsKey(ConcertEditField.time),
                  hintText: '00:00',
                  keyboardType: TextInputType.datetime,
                  onChanged: (value) =>
                      _edit(ConcertEditField.time, () => _form.endTime = value),
                ),
              ),
            ],
          ),
          ?_error(ConcertEditField.time),
        ],
      ),
      _UndecidedSection(
        title: '공연 장소',
        undecided: _form.placeUndecided,
        onUndecided: locked
            ? null
            : (value) => _undecided(ConcertEditField.place, value),
        children: [
          AppTextField(
            key: const ValueKey('concertEdit_place'),
            controller: _place,
            enabled: !locked && !_form.placeUndecided,
            invalid: _issues.containsKey(ConcertEditField.place),
            hintText: '공연 장소를 입력해 주세요',
            onChanged: (value) =>
                _edit(ConcertEditField.place, () => _form.place = value),
          ),
          ?_error(ConcertEditField.place),
          AppTextField(
            key: const ValueKey('concertEdit_address'),
            controller: _address,
            enabled: !locked && !_form.placeUndecided,
            invalid: _issues.containsKey(ConcertEditField.address),
            hintText: '주소를 입력해 주세요',
            onChanged: (value) =>
                _edit(ConcertEditField.address, () => _form.address = value),
          ),
          ?_error(ConcertEditField.address),
        ],
      ),
      _UndecidedSection(
        title: '전체 대관비',
        undecided: _form.rentalFeeUndecided,
        onUndecided: locked
            ? null
            : (value) => _undecided(ConcertEditField.rentalFee, value),
        children: [
          AppTextField(
            key: const ValueKey('concertEdit_rentalFee'),
            controller: _rentalFee,
            focusNode: _rentalFeeFocus,
            enabled: !locked && !_form.rentalFeeUndecided,
            invalid: _issues.containsKey(ConcertEditField.rentalFee),
            hintText: '0',
            keyboardType: TextInputType.number,
            suffix: Text(
              '원',
              style: textStyles.body1Regular.copyWith(
                color: colors.labelNormal,
              ),
            ),
            onChanged: _changeRentalFee,
          ),
          ?_error(ConcertEditField.rentalFee),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x2,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.x1,
                  children: [
                    Text(
                      '모집 팀 수',
                      style: textStyles.title2SemiBold.copyWith(
                        color: colors.labelNormal,
                      ),
                    ),
                    Text(
                      '우리 팀 제외 / 대표자만 바꿀 수 있어요',
                      style: textStyles.caption1Regular.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                  ],
                ),
              ),
              AppStepper(
                key: const ValueKey('concertEdit_recruitTeamCount'),
                valueLabel: '${_form.recruitTeamCount}팀',
                // 화면 노출 기준은 주최 대표자 여부. 최종 판단은 서버가 한다.
                onDecrement:
                    canChangeTeams &&
                        _form.recruitTeamCount > _form.minRecruitTeamCount
                    ? () => _edit(
                        ConcertEditField.recruitTeamCount,
                        () => _form.recruitTeamCount--,
                      )
                    : null,
                onIncrement:
                    canChangeTeams &&
                        _form.recruitTeamCount < ConcertEditForm.maxInteger
                    ? () => _edit(
                        ConcertEditField.recruitTeamCount,
                        () => _form.recruitTeamCount++,
                      )
                    : null,
              ),
            ],
          ),
          ?_error(ConcertEditField.recruitTeamCount),
        ],
      ),
    ];

    return PopScope(
      canPop: _leaving || status == ConcertEditStatus.saved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop &&
            (status == ConcertEditStatus.editing ||
                status == ConcertEditStatus.unconfirmed)) {
          _close();
        }
      },
      child: _Frame(
        onClose:
            status == ConcertEditStatus.saving ||
                status == ConcertEditStatus.saved
            ? null
            : _close,
        body: ListView.separated(
          key: const ValueKey('concertEdit_scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x2_5,
            AppSpacing.x5,
            AppSpacing.x6,
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) => sections[index],
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.x6),
        ),
        bottom: SizedBox(
          width: double.infinity,
          child: AppButton(
            key: const ValueKey('concertEdit_save'),
            label: status == ConcertEditStatus.unconfirmed
                ? '저장 결과 확인'
                : '수정 완료',
            loading: status == ConcertEditStatus.saving,
            onPressed:
                status == ConcertEditStatus.unconfirmed ||
                    (!locked && _form.isDirty)
                ? _submit
                : null,
          ),
        ),
      ),
    );
  }

  Widget? _error(ConcertEditField field) {
    final issue = _issues[field];
    if (issue == null) return null;
    return Text(
      _serverReasons[field] ?? _issueText(field, issue),
      key: ValueKey('concertEdit_${field.name}_error'),
      style: context.textStyles.caption1Regular.copyWith(
        color: context.colors.statusDestructive,
      ),
    );
  }
}

/// Figma `공연정보수정`의 시간·장소·대관비 칸: 제목 오른쪽에 "아직 미정이에요" 체크가 있는 FormSection.
/// 공통 [AppFormSection]에는 제목 옆 자리가 없어, 같은 글자 스타일·간격으로 머리줄만 따로 만든다.
class _UndecidedSection extends StatelessWidget {
  const _UndecidedSection({
    required this.title,
    required this.undecided,
    required this.onUndecided,
    required this.children,
  });

  final String title;
  final bool undecided;
  final ValueChanged<bool>? onUndecided;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final onUndecided = this.onUndecided;
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
            // 글자를 눌러도 체크가 바뀌게 한다. 읽는 이름은 체크박스에 둔다.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onUndecided == null ? null : () => onUndecided(!undecided),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppCheckbox(
                    key: ValueKey('concertEdit_undecided_$title'),
                    checked: undecided,
                    onChanged: onUndecided,
                    semanticLabel: '$title 아직 미정이에요',
                  ),
                  ExcludeSemantics(
                    child: Text(
                      '아직 미정이에요',
                      style: textStyles.body1Regular.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ...children,
      ],
    );
  }
}

/// 확인 팝업의 한 줄: `이름 · 전 → 후`. 비어 있는 값은 미정으로 보인다.
QrListCardRow _changeRow(
  ConcertEditField field,
  ConcertUpdate before,
  ConcertUpdate after,
) {
  final showYear = switch ((before.performDate, after.performDate)) {
    (final String oldDate, final String newDate) =>
      oldDate.substring(0, 4) != newDate.substring(0, 4),
    _ => false,
  };
  String change(String? Function(ConcertUpdate) value) =>
      '${value(before) ?? '미정'} → ${value(after) ?? '미정'}';
  String? time(String? value) =>
      value == null || value.length < 5 ? value : value.substring(0, 5);
  return switch (field) {
    ConcertEditField.title => (
      label: '공연 제목',
      value: change((update) => update.title),
    ),
    ConcertEditField.genres => (
      label: '연주 장르',
      value: change((update) => update.genres.map(concertGenreName).join(', ')),
    ),
    ConcertEditField.performDate => (
      label: '공연 날짜',
      value: change(
        (update) => switch (update.performDate) {
          final date? =>
            showYear ? concertDateLabel(date) : concertShortDateLabel(date),
          null => null,
        },
      ),
    ),
    ConcertEditField.time => (
      label: '공연 시간',
      value: change(
        (update) => update.startTime == null || update.endTime == null
            ? null
            : '${time(update.startTime)} ~ ${time(update.endTime)}',
      ),
    ),
    ConcertEditField.place => (
      label: '공연 장소',
      value: change((update) => update.place),
    ),
    ConcertEditField.address => (
      label: '공연 주소',
      value: change((update) => update.address),
    ),
    ConcertEditField.rentalFee => (
      label: '전체 대관비',
      value: change(
        (update) => switch (update.rentalFee) {
          final fee? => '${_commas('$fee')}원',
          null => null,
        },
      ),
    ),
    ConcertEditField.recruitTeamCount => (
      label: '모집 팀 수',
      value: change((update) => '${update.recruitTeamCount}팀'),
    ),
  };
}

/// 숫자 글자를 세 자리마다 쉼표로 나눈다.
String _commas(String digits) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

/// 입력칸 아래 오류 문구 (명세 1.3 "에러"의 앱 처리).
String _issueText(ConcertEditField field, ConcertEditIssue issue) => switch ((
  field,
  issue,
)) {
  (ConcertEditField.title, ConcertEditIssue.empty) => '공연 제목을 입력해 주세요.',
  (ConcertEditField.title, ConcertEditIssue.tooLong) =>
    '공연 제목은 30자까지 입력할 수 있어요.',
  (ConcertEditField.genres, ConcertEditIssue.empty) => '연주 장르를 하나 이상 골라 주세요.',
  (_, ConcertEditIssue.pastDate) => '오늘 이후 날짜를 골라 주세요.',
  (_, ConcertEditIssue.beforeRecruitDeadline) => '모집 공고 마감일보다 이른 날짜는 고를 수 없어요.',
  (ConcertEditField.time, ConcertEditIssue.empty) => '시작 시간과 종료 시간을 입력해 주세요.',
  (_, ConcertEditIssue.timePair) => '시작 시간과 종료 시간을 함께 입력해 주세요.',
  (_, ConcertEditIssue.timeFormat) => '시간을 00:00 형식으로 입력해 주세요.',
  (ConcertEditField.place, ConcertEditIssue.empty) => '공연 장소를 입력해 주세요.',
  (ConcertEditField.place, ConcertEditIssue.tooLong) => '장소는 100자까지 입력할 수 있어요.',
  (ConcertEditField.address, ConcertEditIssue.tooLong) =>
    '주소는 200자까지 입력할 수 있어요.',
  (ConcertEditField.rentalFee, ConcertEditIssue.empty) => '전체 대관비를 입력해 주세요.',
  (_, ConcertEditIssue.rentalFeeFormat) => '대관비는 2,147,483,647원까지 숫자로 입력해 주세요.',
  (_, ConcertEditIssue.belowJoinedTeams) => '이미 합류한 팀 수보다 적게 줄일 수 없어요.',
  _ => '입력값을 확인해 주세요.',
};
