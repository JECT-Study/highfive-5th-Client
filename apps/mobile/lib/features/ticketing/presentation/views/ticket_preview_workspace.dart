import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../models/ticket_application_page.dart';
import '../../models/ticket_role.dart';
import '../../models/ticket_schedule.dart';
import '../providers/ticket_settings_providers.dart';
import '../view_models/ticket_settings_view_model.dart';
import '../widgets/ticket_settings_section.dart';
import '../widgets/ticket_description_section.dart';
import 'ticket_page_view.dart';

/// 명세 없음: 경로의 설정 폼과 합성 dev 세션 메모리의 생성 상태를 연결한다.
/// J162는 createdBuilder의 읽기 전용 source로 저장 일정에 접근한다.
/// Layout: 페이지와 설정 폼은 각각 하나의 세로 스크롤을 소유한다.
class TicketPreviewWorkspace extends StatefulWidget {
  const TicketPreviewWorkspace({
    super.key,
    this.concertId = ticketPreviewConcertId,
    this.actorId = ticketPreviewActorId,
    this.role = TicketRole.outsider,
    this.createdBuilder,
    this.actorScope,
  });

  final String concertId;
  final String actorId;
  final TicketRole role;
  final ValueListenable<TicketPageScope>? actorScope;
  final Widget Function(
    BuildContext context,
    TicketApplicationPage page,
    TicketScheduleSource schedule,
  )?
  createdBuilder;

  @override
  State<TicketPreviewWorkspace> createState() => _TicketPreviewWorkspaceState();
}

class _TicketPreviewWorkspaceState extends State<TicketPreviewWorkspace> {
  Object _epoch = Object();

  @override
  void initState() {
    super.initState();
    widget.actorScope?.addListener(_changed);
  }

  void _changed() => setState(() => _epoch = Object());

  @override
  void didUpdateWidget(covariant TicketPreviewWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actorScope != widget.actorScope) {
      oldWidget.actorScope?.removeListener(_changed);
      widget.actorScope?.addListener(_changed);
      _epoch = Object();
    }
  }

  @override
  void dispose() {
    widget.actorScope?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope =
        widget.actorScope?.value ??
        (
          concertId: widget.concertId,
          actorId: widget.actorId,
          role: widget.role,
        );
    return _ScopedWorkspace(
      key: ValueKey((scope, widget.actorScope, _epoch)),
      scope: scope,
      createdBuilder: widget.createdBuilder,
      actorScope: widget.actorScope,
    );
  }
}

class _ScopedWorkspace extends ConsumerStatefulWidget {
  const _ScopedWorkspace({
    super.key,
    required this.scope,
    this.createdBuilder,
    this.actorScope,
  });

  final TicketPageScope scope;
  final ValueListenable<TicketPageScope>? actorScope;
  final Widget Function(
    BuildContext,
    TicketApplicationPage,
    TicketScheduleSource,
  )?
  createdBuilder;

  @override
  ConsumerState<_ScopedWorkspace> createState() => _ScopedWorkspaceState();
}

class _ScopedWorkspaceState extends ConsumerState<_ScopedWorkspace> {
  final _navigator = GlobalKey<NavigatorState>();
  final _route = Object();
  late final TicketSettingsViewModel _model;
  TicketSettingsLeaseKey get _lease =>
      (scope: widget.scope, actorScope: widget.actorScope, route: _route);

  @override
  void initState() {
    super.initState();
    _model = ref.read(ticketSettingsLeaseProvider(_lease));
  }

  Future<bool> _configure() async {
    if (!_model.canEdit) return false;
    final navigator = _navigator.currentState;
    if (navigator == null) return false;
    _model.beginConfiguration();
    final saved = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (context) => _TicketConfiguration(model: _model),
      ),
    );
    return mounted && saved == true;
  }

  @override
  void dispose() {
    _model.revoke();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ticketSettingsLeaseProvider(_lease));
    final parentNavigator = Navigator.of(context);
    return PopScope<Object?>(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _model.revoke();
      },
      child: NavigatorPopHandler<Object?>(
        onPopWithResult: (_) => _navigator.currentState?.maybePop(),
        child: Navigator(
          key: _navigator,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => TicketPageView(
              concertId: widget.scope.concertId,
              actorId: widget.scope.actorId,
              role: widget.scope.role,
              actorScope: widget.actorScope,
              onBack: parentNavigator.canPop()
                  ? () {
                      _model.revoke();
                      parentNavigator.pop();
                    }
                  : null,
              onConfigure: _configure,
              createdBuilder: widget.createdBuilder == null
                  ? null
                  : (context, page) => widget.createdBuilder!(
                      context,
                      page,
                      _model.scheduleSource,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketConfiguration extends StatefulWidget {
  const _TicketConfiguration({required this.model});
  final TicketSettingsViewModel model;

  @override
  State<_TicketConfiguration> createState() => _TicketConfigurationState();
}

class _TicketConfigurationState extends State<_TicketConfiguration> {
  bool _description = false;

  void _back() {
    if (_description) {
      setState(() => _description = false);
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<bool>(
    canPop: !_description,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && _description) _back();
    },
    child: Scaffold(
      appBar: AppTopBar(
        title: '티켓 신청',
        leading: AppIconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          tooltip: '뒤로가기',
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: ValueKey(_description),
          child: _description
              ? TicketDescriptionSection(
                  model: widget.model,
                  onSaved: (_) => Navigator.of(context).pop(true),
                )
              : TicketSettingsSection(
                  role: widget.model.scope.role,
                  concert: widget.model.concert,
                  actorId: widget.model.scope.actorId,
                  viewModel: widget.model,
                  onContinue: () => setState(() => _description = true),
                ),
        ),
      ),
    ),
  );
}
