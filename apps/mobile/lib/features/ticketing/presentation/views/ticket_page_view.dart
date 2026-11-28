import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_notice.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../models/ticket_application_page.dart';
import '../../models/ticket_role.dart';
import '../view_models/ticket_page_view_model.dart';

/// 명세 없음: dev 라우트에서만 여는 합성 공연의 로컬 생성 미리보기.
/// Layout: 단일 ListView가 공연 요약 → 생성 상태 → 주 동작 순서로 스크롤한다.
class TicketPageView extends ConsumerStatefulWidget {
  const TicketPageView({
    super.key,
    this.concertId = ticketPreviewConcertId,
    this.actorId = ticketPreviewActorId,
    this.role = TicketRole.outsider,
    this.actorScope,
    this.onConfigure,
    this.createdBuilder,
    this.onBack,
  });

  final String concertId;
  final String actorId;
  final TicketRole role;

  /// 변경 가능한 미리보기의 원본. 전환 즉시 검사하려면 이 원본을 전달한다.
  final ValueListenable<TicketPageScope>? actorScope;
  final Future<bool> Function()? onConfigure;
  final Widget Function(BuildContext, TicketApplicationPage)? createdBuilder;
  final VoidCallback? onBack;

  static const createKey = ValueKey('ticket_page_create');
  static const createdKey = ValueKey('ticket_page_created');
  static const deniedKey = ValueKey('ticket_page_denied');
  static const retryKey = ValueKey('ticket_page_retry');
  static const loadingKey = ValueKey('ticket_page_loading');
  static const unknownKey = ValueKey('ticket_page_unknown');

  @override
  ConsumerState<TicketPageView> createState() => _TicketPageViewState();
}

class _TicketPageViewState extends ConsumerState<TicketPageView> {
  bool _configuring = false;
  bool _configurationFailed = false;
  Object _actorEpoch = Object();

  TicketPageScope get _scope =>
      widget.actorScope?.value ??
      (concertId: widget.concertId, actorId: widget.actorId, role: widget.role);

  @override
  void initState() {
    super.initState();
    widget.actorScope?.addListener(_actorChanged);
  }

  void _actorChanged() {
    _actorEpoch = Object();
    setState(() {
      _configuring = false;
      _configurationFailed = false;
    });
  }

  @override
  void didUpdateWidget(covariant TicketPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actorScope != widget.actorScope) {
      oldWidget.actorScope?.removeListener(_actorChanged);
      widget.actorScope?.addListener(_actorChanged);
    }
    if (oldWidget.concertId != widget.concertId ||
        oldWidget.actorId != widget.actorId ||
        oldWidget.role != widget.role ||
        oldWidget.actorScope != widget.actorScope) {
      _actorEpoch = Object();
      _configuring = false;
      _configurationFailed = false;
    }
  }

  @override
  void dispose() {
    widget.actorScope?.removeListener(_actorChanged);
    super.dispose();
  }

  Future<void> _create(
    Object renderedEpoch,
    TicketPageScope renderedScope,
  ) async {
    if (_configuring ||
        renderedEpoch != _actorEpoch ||
        renderedScope != _scope ||
        _scope.role != ticketPageRequiredRole) {
      return;
    }
    final scope = renderedScope;
    if (ref.read(ticketPageViewModelProvider(scope)).value?.canCreate != true) {
      return;
    }
    final epoch = _actorEpoch;
    setState(() {
      _configuring = true;
      _configurationFailed = false;
    });
    try {
      final confirmed =
          await (widget.onConfigure?.call() ?? Future.value(true));
      // 다른 화면의 구독 유무나 TickerMode와 무관하게 이 화면의 actor를 검사한다.
      if (!mounted || epoch != _actorEpoch || scope != _scope || !confirmed) {
        return;
      }
      await ref.read(ticketPageViewModelProvider(scope).notifier).create();
    } on Object {
      if (mounted && epoch == _actorEpoch) {
        setState(() => _configurationFailed = true);
      }
    } finally {
      if (mounted && epoch == _actorEpoch) {
        setState(() => _configuring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final renderedEpoch = _actorEpoch;
    final renderedScope = _scope;
    final provider = ticketPageViewModelProvider(renderedScope);
    final result = ref.watch(provider);
    final vm = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppTopBar(
        title: '합동 공연',
        leading: widget.onBack != null || Navigator.of(context).canPop()
            ? AppIconButton(
                icon: const AppIcon(AppIcons.arrowBack),
                tooltip: '뒤로가기',
                onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.x5),
          children: [
            Text(
              '데모 합동공연',
              style: context.textStyles.title1Bold.copyWith(
                color: context.colors.labelNormal,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              '합성 공연 · 로컬 미리보기',
              style: context.textStyles.caption1Regular.copyWith(
                color: context.colors.labelAlternative,
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
            Text('티켓 관리', style: context.textStyles.title2Bold),
            const SizedBox(height: AppSpacing.x8),
            result.when(
              loading: () => Column(
                key: TicketPageView.loadingKey,
                spacing: AppSpacing.x4,
                children: [
                  const SizedBox.square(
                    dimension: AppSpacing.x6,
                    child: CircularProgressIndicator(
                      semanticsLabel: '생성 상태 확인 중',
                    ),
                  ),
                  Text(
                    '생성 상태를 확인하고 있어요',
                    style: context.textStyles.body1Regular,
                  ),
                ],
              ),
              error: (error, stack) => _failure(context, switch (error) {
                TicketPageFailure(:final reason) => reason,
                _ => TicketPageFailureReason.unavailable,
              }, vm.retryLoad),
              data: (data) {
                if (data.page case final page?) {
                  return KeyedSubtree(
                    key: TicketPageView.createdKey,
                    child:
                        widget.createdBuilder?.call(context, page) ??
                        const AppNotice(
                          message: '미리보기 페이지가 만들어졌어요. 실제 신청 링크는 발행되지 않아요.',
                        ),
                  );
                }
                if (data.failure == TicketPageFailureReason.outcomeUnknown) {
                  return KeyedSubtree(
                    key: TicketPageView.unknownKey,
                    child: _failure(
                      context,
                      TicketPageFailureReason.outcomeUnknown,
                      vm.checkOutcome,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.x5,
                  children: [
                    const AppIcon(AppIcons.ticket),
                    Text(
                      '아직 티켓을 열지 않았어요',
                      textAlign: TextAlign.center,
                      style: context.textStyles.title2Bold,
                    ),
                    if (_configurationFailed)
                      const AppNotice(message: '설정을 열지 못했어요. 다시 시도해 주세요.'),
                    Text(
                      '이 기기에서만 설정을 미리 봐요.\n실제 링크는 발행하지 않아요.',
                      textAlign: TextAlign.center,
                      style: context.textStyles.body1Regular.copyWith(
                        color: context.colors.labelAlternative,
                      ),
                    ),
                    if (data.failure case final failure?)
                      _failure(
                        context,
                        failure,
                        () => _create(renderedEpoch, renderedScope),
                      ),
                    if (_scope.role == ticketPageRequiredRole)
                      AppButton(
                        key: TicketPageView.createKey,
                        label: '티켓 신청 페이지 만들기',
                        loading: data.creating || _configuring,
                        onPressed: data.canCreate && !_configuring
                            ? () => _create(renderedEpoch, renderedScope)
                            : null,
                      )
                    else
                      const AppNotice(
                        key: TicketPageView.deniedKey,
                        message: '주최 대표자만 만들 수 있어요.',
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _failure(
    BuildContext context,
    TicketPageFailureReason reason,
    VoidCallback retry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x3,
      children: [
        AppNotice(
          key: reason == TicketPageFailureReason.forbidden
              ? TicketPageView.deniedKey
              : null,
          message: switch (reason) {
            TicketPageFailureReason.forbidden =>
              '이 공연의 미리보기를 열 권한이 없어요. 합성 사용자 역할을 확인해 주세요.',
            TicketPageFailureReason.unavailable =>
              '생성 상태를 확인하지 못했어요. 다시 시도해 주세요.',
            TicketPageFailureReason.outcomeUnknown =>
              '생성 결과를 확인 중이에요. 다시 만들지 말고 결과를 확인해 주세요.',
          },
        ),
        if (reason != TicketPageFailureReason.forbidden)
          AppButton(
            key: TicketPageView.retryKey,
            label: reason == TicketPageFailureReason.outcomeUnknown
                ? '생성 결과 확인하기'
                : '다시 시도하기',
            onPressed: retry,
            variant: AppButtonVariant.weak,
          ),
      ],
    );
  }
}
