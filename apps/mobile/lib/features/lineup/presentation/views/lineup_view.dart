import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/show/show_lineup_item.dart';
import '../../../../shared/widgets/show/show_meta_text.dart';
import '../../models/lineup.dart';
import '../view_models/lineup_view_models.dart';
import '../widgets/lineup_feedback.dart';
import '../widgets/lineup_formats.dart';
import '../widgets/lineup_slot_settings.dart';

/// 공연 라인업 (Figma 정보 탭 라인업 블록 `2220:137235`, 화면 `3팀 모집, 1팀 들어온 상태` 2217:123232).
///
/// 합류한 팀은 서버가 공연 순서대로 모두 준다 (명세 1.4). 카드를 끌어 놓으면 전체 순서를 저장하고 (1.10),
/// 누르면 그 팀의 셋리스트를 연다. 순서 칸에서는 이미 합류한 팀을 선택해 그 위치로 옮긴다.
/// 빈 모집 슬롯은 편집하지 않는다.
class LineupView extends ConsumerStatefulWidget {
  const LineupView({
    super.key,
    required this.concertId,
    required this.onOpenSetlist,
  });

  final int concertId;

  /// 팀 카드를 눌렀다. 셋리스트 화면이 닫힐 때 끝나는 Future를 돌려준다 (그동안 다시 열지 않는다).
  final Future<void> Function(int bandId) onOpenSetlist;

  static const backKey = ValueKey('lineup_back');
  static const loadingKey = ValueKey('lineup_loading');
  static const errorKey = ValueKey('lineup_error');
  static const retryKey = ValueKey('lineup_retry');
  static const emptyKey = ValueKey('lineup_empty');
  static const listKey = ValueKey('lineup_list');
  static const emptySlotKey = ValueKey('lineup_emptySlot');
  static const savingKey = ValueKey('lineup_saving');
  static ValueKey<String> teamKey(int bandId) =>
      ValueKey('lineup_team_$bandId');
  static ValueKey<String> dragHandleKey(int bandId) =>
      ValueKey('lineup_dragHandle_$bandId');
  static ValueKey<String> positionKey(int index) =>
      ValueKey('lineup_position_$index');

  @override
  ConsumerState<LineupView> createState() => _LineupViewState();
}

/// 빈자리 안내 (Figma `Line up` 합류 준비).
const _emptySlotMessage = '합류한 팀이 순서대로 여기에 쌓여요';

class _LineupViewState extends ConsumerState<LineupView> {
  /// 끌어 놓은 순서. 저장하는 동안 이 순서를 보여 주고, 끝나면 서버 결과(실패면 원래 순서)를 따른다.
  List<LineupTeam>? _pendingTeams;

  /// 셋리스트를 여는 중이면 같은 카드를 두 번 눌러도 한 번만 연다.
  bool _opening = false;
  bool _settingPosition = false;

  Future<void> _openPosition(List<LineupTeam> teams, int target) async {
    if (_settingPosition) return;
    _settingPosition = true;
    final snapshot = List<LineupTeam>.of(teams);
    final selected = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            LineupSlotSettings(teams: snapshot, targetIndex: target),
      ),
    );
    _settingPosition = false;
    if (!mounted || selected == null) return;
    final current = ref.read(lineupProvider(widget.concertId));
    final latest = current.value?.teams;
    final stale =
        current.isLoading ||
        current.hasError ||
        latest == null ||
        latest.length != snapshot.length ||
        List.generate(snapshot.length, (i) => i).any(
          (i) =>
              latest[i].concertTeamId != snapshot[i].concertTeamId ||
              latest[i].band.bandId != snapshot[i].band.bandId ||
              latest[i].lineupOrder != snapshot[i].lineupOrder,
        );
    if (stale) {
      showLineupToast(context, '라인업이 변경되었습니다. 최신 정보를 확인해 주세요.');
      ref.read(lineupProvider(widget.concertId).notifier).retry();
      return;
    }
    await _reorder(
      snapshot,
      snapshot.indexWhere((team) => team.band.bandId == selected),
      target,
    );
  }

  /// [newIndex]는 옮길 팀을 뺀 뒤의 위치다 (`onReorderItem`, ViewModel과 같은 기준).
  Future<void> _reorder(
    List<LineupTeam> teams,
    int oldIndex,
    int newIndex,
  ) async {
    if (ref.read(lineupWriteProvider(widget.concertId)).isSaving) return;
    final moved = [...teams];
    moved.insert(newIndex, moved.removeAt(oldIndex));
    setState(() => _pendingTeams = moved);
    await ref
        .read(lineupProvider(widget.concertId).notifier)
        .reorder(oldIndex, newIndex);
    if (mounted) setState(() => _pendingTeams = null);
  }

  Future<void> _openSetlist(int bandId) async {
    if (_opening) return;
    _opening = true;
    try {
      await widget.onOpenSetlist(bandId);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lineupProvider(widget.concertId));
    final saving = ref.watch(
      lineupWriteProvider(widget.concertId).select((write) => write.isSaving),
    );
    ref.listen(lineupWriteProvider(widget.concertId), (previous, next) {
      // 순서 저장이 끝났는데 오류·안내(409 등)가 남았으면 한 번 알린다.
      if (previous?.isSaving != true || next.isSaving) return;
      if (next.error == null && next.message == null) return;
      showLineupToast(
        context,
        next.message ??
            failureMessage(next.error, '공연 순서를 바꾸지 못했어요. 다시 시도해 주세요.'),
      );
    });

    final lineup = state.value;
    final failed = state.hasError && !state.isLoading;
    return Scaffold(
      appBar: AppTopBar(
        leading: Navigator.of(context).canPop()
            ? AppIconButton(
                key: LineupView.backKey,
                icon: const AppIcon(AppIcons.arrowBack),
                tooltip: '뒤로',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: failed
            ? LineupLoadFailure(
                key: LineupView.errorKey,
                retryKey: LineupView.retryKey,
                title: '라인업을 불러오지 못했어요.',
                message: failureMessage(state.error, '잠시 후 다시 시도해 주세요.'),
                onRetry: () =>
                    ref.read(lineupProvider(widget.concertId).notifier).retry(),
              )
            : lineup == null
            ? const LineupLoading(key: LineupView.loadingKey)
            : _content(lineup, saving: saving, reloading: state.isLoading),
      ),
    );
  }

  Widget _content(
    Lineup lineup, {
    required bool saving,
    required bool reloading,
  }) {
    final teams = _pendingTeams ?? lineup.teams;
    return ListView(
      // Figma `Section`: 위아래 20, 머리글과 목록 사이 16
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x5),
      children: [
        _LineupHeader(teamCount: teams.length, saving: saving),
        const SizedBox(height: AppSpacing.x4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
          child: teams.isEmpty
              ? const ShowLineupPlaceholder(
                  key: LineupView.emptyKey,
                  message: _emptySlotMessage,
                )
              : _LineupTimeline(
                  teams: teams,
                  showEmptySlot: lineup.emptySlotCount > 0,
                  // 저장·다시 불러오기 중에는 순서를 바꾸지 않는다 (ViewModel도 무시한다).
                  reorderEnabled: !saving && !reloading,
                  onReorder: (oldIndex, newIndex) =>
                      _reorder(teams, oldIndex, newIndex),
                  onOpenSetlist: _openSetlist,
                  onOpenPosition: (index) => _openPosition(teams, index),
                ),
        ),
      ],
    );
  }
}

/// "라인업 N팀 · 시간 미정" (Figma `Section`의 `Row`).
class _LineupHeader extends StatelessWidget {
  const _LineupHeader({required this.teamCount, required this.saving});

  final int teamCount;
  final bool saving;

  static const _savingSize = 16.0; // 머리글 줄에 맞춘 작은 저장 중 표시 (시안 없음)
  static const _savingStroke = 2.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
      child: Row(
        spacing: AppSpacing.x2,
        children: [
          Text(
            '라인업',
            style: context.textStyles.title1Bold.copyWith(
              color: colors.labelNormal,
            ),
          ),
          // 팀별 공연 시간은 서버가 주지 않는다 (명세 1.4 FE 참고).
          Expanded(child: ShowMetaText(['$teamCount팀', '시간 미정'])),
          if (saving)
            SizedBox.square(
              key: LineupView.savingKey,
              dimension: _savingSize,
              child: CircularProgressIndicator(
                strokeWidth: _savingStroke,
                color: colors.labelAssistive,
              ),
            ),
        ],
      ),
    );
  }
}

/// Figma 시간 칸: "미정"(글자 42) + 간격 6 + 원 표시(8). 카드는 그 오른쪽 14에서 시작한다.
const _timeColumnWidth = 56.0;

/// 라인업 블록: 왼쪽 시간 줄(미정 · 원 표시 · 세로선), 팀 카드, 빈자리 안내.
/// 팀별 공연 시간이 없어 시간 글자는 첫 카드 옆 "미정" 하나다.
class _LineupTimeline extends StatelessWidget {
  const _LineupTimeline({
    required this.teams,
    required this.showEmptySlot,
    required this.reorderEnabled,
    required this.onReorder,
    required this.onOpenSetlist,
    required this.onOpenPosition,
  });

  final List<LineupTeam> teams;
  final bool showEmptySlot;
  final bool reorderEnabled;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<int> onOpenSetlist;
  final ValueChanged<int> onOpenPosition;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: ReorderableListView.builder(
                key: LineupView.listKey,
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                // 카드에 바탕이 있어 끌 때 따로 그리지 않는다.
                proxyDecorator: (child, _, _) =>
                    Material(type: MaterialType.transparency, child: child),
                itemCount: teams.length,
                onReorderItem: onReorder,
                itemBuilder: _teamItem,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: _timeColumnWidth,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _RailPainter(
                    lineColor: colors.labelAlternative,
                    markerFill: colors.backgroundNormal,
                    markerStroke: colors.labelNormal,
                    markerY: _RailPainter.startMarkerY,
                    lineBelow: showEmptySlot || teams.length > 1,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
        if (showEmptySlot)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x3_5,
              children: [
                SizedBox(
                  width: _timeColumnWidth,
                  child: CustomPaint(
                    painter: _RailPainter(
                      lineColor: colors.labelAlternative,
                      markerFill: colors.backgroundNormal,
                      markerStroke: colors.labelAlternative,
                      topInset: AppSpacing.x2_5,
                      lineAbove: true,
                      dashedMarker: true,
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    // Figma `WrapList`: 팀 카드와 빈자리 사이 10
                    padding: EdgeInsets.only(top: AppSpacing.x2_5),
                    child: ShowLineupPlaceholder(
                      key: LineupView.emptySlotKey,
                      message: _emptySlotMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _teamItem(BuildContext context, int index) {
    final team = teams[index];
    final band = team.band;
    final imageUrl = band.profileImageUrl;
    final hiddenSongs = team.setlistTotalCount - team.setlistPreview.length;
    return Padding(
      key: ValueKey(band.bandId),
      // Figma `Wrap`: 카드 사이 14
      padding: EdgeInsets.only(
        bottom: index == teams.length - 1 ? 0 : AppSpacing.x3_5,
      ),
      // 스크롤을 순서 변경으로 저장하지 않도록 길게 누른 뒤 카드를 끈다.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.x3_5,
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Semantics(
              label: '${index + 1}번째 공연 순서 설정',
              child: TextButton(
                key: LineupView.positionKey(index),
                onPressed: reorderEnabled ? () => onOpenPosition(index) : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: context.colors.labelNeutral,
                  textStyle: context.textStyles.caption1Medium,
                ),
                child: Text('${index + 1}번째'),
              ),
            ),
          ),
          Expanded(
            child: ReorderableDelayedDragStartListener(
              key: LineupView.dragHandleKey(band.bandId),
              index: index,
              enabled: reorderEnabled,
              child: ShowLineupItem(
                key: LineupView.teamKey(band.bandId),
                name: band.name,
                roleLabel: team.isHost ? '주최' : null,
                details: [
                  if (band.genres.isNotEmpty) genreNames(band.genres),
                  '${band.memberCount}명',
                ],
                setList: team.setlistPreview,
                // 명세 1.4: 앞 3곡만 오고, 넘는 곡 수는 "+N"으로 보인다.
                setListMoreLabel: hiddenSongs > 0 ? '+$hiddenSongs' : null,
                image: imageUrl == null ? null : NetworkImage(imageUrl),
                onTap: () => onOpenSetlist(band.bandId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 시간 칸의 원 표시와 세로선 (Figma `TimelineMarker` 지름 8·테두리 1.5, `line` 1).
///
/// 첫 칸은 원을 [markerY]에 그리고 아래로 선을 잇는다. 빈자리 칸은 [topInset] 아래 영역의 가운데에
/// 점선 원을 그리고 위에서 선을 받는다.
class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.lineColor,
    required this.markerFill,
    required this.markerStroke,
    this.markerY,
    this.topInset = 0,
    this.lineAbove = false,
    this.lineBelow = false,
    this.dashedMarker = false,
  });

  /// Figma: 칸 위에서 원 중심까지 (원 위쪽 21 + 반지름 4).
  static const startMarkerY = 25.0;

  static const _centerX = 52.0; // Figma: "미정" 42 + 간격 6 + 반지름 4
  static const _radius = 4.0;
  static const _markerStrokeWidth = 1.5;
  static const _lineWidth = 1.0;
  static const _dash = 2.0; // 점선 원: 2 칠하고 2 띄움 (ImageInput 점선과 같다)

  final Color lineColor;
  final Color markerFill;
  final Color markerStroke;

  /// 원 중심 높이. null이면 [topInset] 아래 영역의 가운데.
  final double? markerY;
  final double topInset;
  final bool lineAbove;
  final bool lineBelow;
  final bool dashedMarker;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = markerY ?? topInset + (size.height - topInset) / 2;
    final center = Offset(_centerX, centerY);
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = _lineWidth;
    if (lineAbove) {
      canvas.drawLine(
        const Offset(_centerX, 0),
        Offset(_centerX, centerY - _radius),
        line,
      );
    }
    if (lineBelow) {
      canvas.drawLine(
        Offset(_centerX, centerY + _radius),
        Offset(_centerX, size.height),
        line,
      );
    }
    canvas.drawCircle(center, _radius, Paint()..color = markerFill);
    final stroke = Paint()
      ..color = markerStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = _markerStrokeWidth;
    if (!dashedMarker) {
      canvas.drawCircle(center, _radius, stroke);
      return;
    }
    final circle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: _radius));
    for (final metric in circle.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash * 2) {
        canvas.drawPath(metric.extractPath(start, start + _dash), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.markerFill != markerFill ||
      oldDelegate.markerStroke != markerStroke ||
      oldDelegate.markerY != markerY ||
      oldDelegate.topInset != topInset ||
      oldDelegate.lineAbove != lineAbove ||
      oldDelegate.lineBelow != lineBelow ||
      oldDelegate.dashedMarker != dashedMarker;
}
