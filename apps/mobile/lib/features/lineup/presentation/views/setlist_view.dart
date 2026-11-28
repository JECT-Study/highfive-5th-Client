import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_shadows.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../models/lineup.dart';
import '../view_models/lineup_view_models.dart';
import '../widgets/lineup_feedback.dart';
import '../widgets/lineup_formats.dart';
import '../widgets/setlist_band_card.dart';
import '../widgets/song_add_sheet.dart';
import '../widgets/song_row.dart';

/// 한 팀의 셋리스트 (Figma 보기 `라인업->각 밴드 셋리스트 페이지` 2217:124273,
/// 편집 `셋리스트-편집` 2217:124234, 빈 상태 `셋리스트-아직 추가하지 않았을 때` 2217:124309).
///
/// 편집(곡 추가·빼기·순서 바꾸기)은 화면 안 초안에서만 하고, "완료"에서 목록 전체를 한 번 저장한다 (명세 1.8).
/// 저장이 실패하면 초안을 그대로 둬서 다시 "완료"를 누를 수 있다.
/// "편집"·"곡 추가"는 `canEdit`(그 밴드의 멤버)일 때만 보인다. 최종 권한은 서버가 판단한다.
class SetlistView extends ConsumerStatefulWidget {
  const SetlistView({super.key, required this.concertId, required this.bandId});

  final int concertId;
  final int bandId;

  static const backKey = ValueKey('setlist_back');
  static const editKey = ValueKey('setlist_edit');
  static const doneKey = ValueKey('setlist_done');
  static const loadingKey = ValueKey('setlist_loading');
  static const errorKey = ValueKey('setlist_error');
  static const retryKey = ValueKey('setlist_retry');
  static const emptyKey = ValueKey('setlist_empty');
  static const emptyAddKey = ValueKey('setlist_emptyAdd');
  static const addSongKey = ValueKey('setlist_addSong');
  static const songCountKey = ValueKey('setlist_songCount');
  static ValueKey<String> songKey(int index) => ValueKey('setlist_song_$index');
  static ValueKey<String> dragHandleKey(int index) =>
      ValueKey('setlist_dragHandle_$index');
  static ValueKey<String> removeKey(int index) =>
      ValueKey('setlist_remove_$index');

  @override
  ConsumerState<SetlistView> createState() => _SetlistViewState();
}

/// 편집 중인 곡 한 줄. 같은 곡이 두 번 있어도 줄을 구분하도록 화면 안 번호를 붙인다.
class _DraftSong {
  const _DraftSong(this.id, this.song);

  final int id;
  final LineupSong song;
}

class _SetlistViewState extends ConsumerState<SetlistView> {
  /// 편집 초안. null이면 보기 모드.
  List<_DraftSong>? _draft;
  int _nextDraftId = 0;

  SetlistKey get _key => (concertId: widget.concertId, bandId: widget.bandId);

  bool get _saving => ref.read(setlistWriteProvider(_key)).isSaving;

  _DraftSong _draftOf(LineupSong song) => _DraftSong(_nextDraftId++, song);

  void _startEditing(BandSetlist setlist, {bool openSongSheet = false}) {
    if (!setlist.canEdit || _saving) return;
    setState(() => _draft = [for (final song in setlist.songs) _draftOf(song)]);
    if (openSongSheet) _openSongSheet();
  }

  /// 편집 취소: 초안을 버리고 서버 목록으로 돌아간다. 저장 중에는 결과를 기다린다.
  void _cancelEditing() {
    if (_saving) return;
    setState(() => _draft = null);
  }

  void _removeSong(int index) {
    final draft = _draft;
    // 줄을 다시 그리기 전에 두 번 눌러도 없는 줄을 지우지 않게 한다.
    if (draft == null || index >= draft.length) return;
    setState(() => draft.removeAt(index));
  }

  /// [newIndex]는 옮길 줄을 뺀 뒤의 위치다 (`onReorderItem`).
  void _moveSong(int oldIndex, int newIndex) {
    final draft = _draft;
    if (draft == null) return;
    setState(() => draft.insert(newIndex, draft.removeAt(oldIndex)));
  }

  Future<void> _openSongSheet() async {
    final draft = _draft;
    if (draft == null) return;
    await showSongAddSheet(
      context,
      addedTrackIds: {for (final entry in draft) ?entry.song.trackId},
      onAdd: (song) {
        if (mounted) setState(() => _draft?.add(_draftOf(song)));
      },
    );
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    final saved = await ref.read(setlistProvider(_key).notifier).save([
      for (final entry in draft) entry.song,
    ]);
    if (!mounted) return;
    // 저장은 됐는데 다시 불러오기만 실패하면 조회 상태가 오류가 된다.
    // 그때 초안은 이미 서버에 있으므로 버리고, 오류 화면의 "다시 시도"로 다시 불러온다.
    if (saved || ref.read(setlistProvider(_key)).hasError) {
      setState(() => _draft = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setlistProvider(_key));
    final saving = ref.watch(
      setlistWriteProvider(_key).select((write) => write.isSaving),
    );
    ref.listen(setlistWriteProvider(_key), (previous, next) {
      // 저장이 끝났는데 오류·안내가 남았으면 한 번 알린다.
      if (previous?.isSaving != true || next.isSaving) return;
      if (next.error == null && next.message == null) return;
      showLineupToast(
        context,
        next.message ??
            failureMessage(next.error, '셋리스트를 저장하지 못했어요. 다시 시도해 주세요.'),
      );
    });

    final setlist = state.value;
    final failed = state.hasError && !state.isLoading;
    final draft = failed || setlist == null ? null : _draft;
    final editing = draft != null;

    final Widget? leading = editing
        ? AppIconButton(
            key: SetlistView.backKey,
            icon: const AppIcon(AppIcons.arrowBack),
            tooltip: '편집 취소',
            onPressed: saving ? null : _cancelEditing,
          )
        : Navigator.of(context).canPop()
        ? AppIconButton(
            key: SetlistView.backKey,
            icon: const AppIcon(AppIcons.arrowBack),
            tooltip: '뒤로',
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : null;
    final Widget? trailing = editing
        ? _TopBarTextButton(
            key: SetlistView.doneKey,
            label: '완료',
            onPressed: saving ? null : _save,
          )
        : setlist != null &&
              !failed &&
              setlist.canEdit &&
              setlist.songs.isNotEmpty
        ? _TopBarTextButton(
            key: SetlistView.editKey,
            label: '편집',
            // 다시 불러오는 중에는 최신 목록으로 편집하도록 기다린다.
            onPressed: saving || state.isLoading
                ? null
                : () => _startEditing(setlist),
          )
        : null;

    return PopScope(
      // 편집 중 뒤로 가기는 화면을 닫지 않고 편집만 취소한다.
      canPop: !editing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelEditing();
      },
      child: Scaffold(
        appBar: AppTopBar(title: '셋리스트', leading: leading, trailing: trailing),
        body: SafeArea(
          top: false,
          child: failed
              ? LineupLoadFailure(
                  key: SetlistView.errorKey,
                  retryKey: SetlistView.retryKey,
                  title: '셋리스트를 불러오지 못했어요.',
                  message: failureMessage(state.error, '잠시 후 다시 시도해 주세요.'),
                  onRetry: () =>
                      ref.read(setlistProvider(_key).notifier).retry(),
                )
              : setlist == null
              ? const LineupLoading(key: SetlistView.loadingKey)
              : _content(setlist, draft, saving: saving),
        ),
      ),
    );
  }

  Widget _content(
    BandSetlist setlist,
    List<_DraftSong>? draft, {
    required bool saving,
  }) {
    final bandName = setlist.band.name;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          // Figma `LineupCell`: 위 12, 양옆·아래 20
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x3,
            AppSpacing.x5,
            AppSpacing.x5,
          ),
          sliver: SliverToBoxAdapter(
            child: SetlistBandCard(band: setlist.band),
          ),
        ),
        const SliverToBoxAdapter(child: AppSectionDivider()),
        if (draft == null && setlist.songs.isEmpty)
          SliverToBoxAdapter(
            child: _EmptySetlist(
              key: SetlistView.emptyKey,
              onAdd: setlist.canEdit && !saving
                  ? () => _startEditing(setlist, openSongSheet: true)
                  : null,
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: _SongListHeader(
              count: draft?.length ?? setlist.songs.length,
            ),
          ),
          if (draft == null)
            SliverList.builder(
              itemCount: setlist.songs.length,
              itemBuilder: (context, index) => _SongViewRow(
                index: index,
                song: setlist.songs[index],
                bandName: bandName,
              ),
            )
          else ...[
            SliverReorderableList(
              itemCount: draft.length,
              onReorderItem: _moveSong,
              proxyDecorator: _liftedRow,
              itemBuilder: (context, index) => _SongEditRow(
                key: ValueKey(draft[index].id),
                index: index,
                song: draft[index].song,
                bandName: bandName,
                enabled: !saving,
                onRemove: () => _removeSong(index),
              ),
            ),
            SliverPadding(
              // Figma: 목록 아래 12, 양옆 20
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x3,
                AppSpacing.x5,
                AppSpacing.x5,
              ),
              sliver: SliverToBoxAdapter(
                child: AppButton(
                  key: SetlistView.addSongKey,
                  label: '곡 추가',
                  variant: AppButtonVariant.weak,
                  // Figma: 24 칸 가운데에 add20을 16으로 놓음
                  icon: const Center(
                    child: AppIcon(AppIcons.add20, size: _addIconSize),
                  ),
                  onPressed: saving ? null : _openSongSheet,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  static const _addIconSize = 16.0;

  /// 끌고 있는 줄을 바탕 위로 띄워 보인다 (시안 없음. 그림자 토큰을 쓴다).
  Widget _liftedRow(Widget child, int index, Animation<double> animation) {
    return DecoratedBox(
      decoration: const BoxDecoration(boxShadow: AppShadows.medium),
      child: Material(color: context.colors.backgroundNormal, child: child),
    );
  }
}

/// Figma `PlayList` 줄의 여백 (보기·편집 공통): 세로 14, 가로 20.
const _songRowPadding = EdgeInsets.symmetric(
  horizontal: AppSpacing.x5,
  vertical: AppSpacing.x3_5,
);

/// "곡 목록 · N곡" 줄 (Figma `List`의 첫 `Row`: 위 14, 아래 8, 양옆 20).
class _SongListHeader extends StatelessWidget {
  const _SongListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x5,
        AppSpacing.x3_5,
        AppSpacing.x5,
        AppSpacing.x2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '곡 목록',
              style: textStyles.body1SemiBold.copyWith(
                color: colors.labelNormal,
              ),
            ),
          ),
          Text(
            '$count곡',
            key: SetlistView.songCountKey,
            style: textStyles.caption1Regular.copyWith(
              color: colors.labelNeutral,
            ),
          ),
        ],
      ),
    );
  }
}

/// 보기 모드 한 줄 (Figma `PlayList` 리스트): 순서 번호, 곡, 재생 시간.
class _SongViewRow extends StatelessWidget {
  const _SongViewRow({
    required this.index,
    required this.song,
    required this.bandName,
  });

  final int index;
  final LineupSong song;
  final String bandName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final duration = song.durationSeconds;
    return SongRow(
      key: SetlistView.songKey(index),
      padding: _songRowPadding,
      leading: Text(
        '${index + 1}',
        style: textStyles.body1SemiBold.copyWith(color: colors.labelNormal),
      ),
      title: song.songTitle,
      subtitle: songSubtitle(song, bandName),
      imageUrl: song.albumImageUrl,
      trailing: duration == null
          ? null
          : Text(
              formatDuration(duration),
              style: textStyles.caption1Regular.copyWith(
                color: colors.labelAlternative,
              ),
            ),
    );
  }
}

/// 편집 모드 한 줄 (Figma `PlayList` 편집): 끌기 손잡이, 곡, 빼기.
class _SongEditRow extends StatelessWidget {
  const _SongEditRow({
    super.key,
    required this.index,
    required this.song,
    required this.bandName,
    required this.enabled,
    required this.onRemove,
  });

  final int index;
  final LineupSong song;
  final String bandName;

  /// 저장 중에는 끌기·빼기를 막는다.
  final bool enabled;
  final VoidCallback onRemove;

  /// Figma `menu`·`ban` 아이콘 크기.
  /// 두 아이콘의 SVG가 아직 `AppIcons`에 없어 Material 아이콘으로 같은 모양을 그린다.
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SongRow(
      key: SetlistView.songKey(index),
      padding: _songRowPadding,
      leading: ReorderableDragStartListener(
        key: SetlistView.dragHandleKey(index),
        index: index,
        enabled: enabled,
        child: Icon(
          Icons.menu,
          size: _iconSize,
          color: colors.labelAssistive,
          semanticLabel: '순서 바꾸기',
        ),
      ),
      title: song.songTitle,
      subtitle: songSubtitle(song, bandName),
      imageUrl: song.albumImageUrl,
      trailing: Semantics(
        button: true,
        enabled: enabled,
        label: '${song.songTitle} 빼기',
        excludeSemantics: true,
        child: GestureDetector(
          key: SetlistView.removeKey(index),
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onRemove : null,
          child: Icon(
            Icons.remove_circle,
            size: _iconSize,
            color: colors.statusDestructive,
          ),
        ),
      ),
    );
  }
}

/// 곡이 없을 때 (Figma `InputImg`를 쓴 "곡 목록" 칸: 위아래 12, 양옆 20, 상자 높이 100).
/// 편집할 수 있으면 +와 함께 눌러서 곡 추가 시트를 열고, 아니면 안내만 보인다.
class _EmptySetlist extends StatelessWidget {
  const _EmptySetlist({super.key, required this.onAdd});

  final VoidCallback? onAdd;

  static const _boxHeight = 100.0; // Figma: Input 상자 높이

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final canAdd = onAdd != null;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x5,
        vertical: AppSpacing.x3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x1_5,
        children: [
          Text(
            '곡 목록',
            style: textStyles.body1SemiBold.copyWith(color: colors.labelNormal),
          ),
          Semantics(
            button: canAdd,
            child: Material(
              color: colors.backgroundAlternative,
              borderRadius: BorderRadius.circular(AppRadius.md),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: canAdd ? SetlistView.emptyAddKey : null,
                onTap: onAdd,
                child: SizedBox(
                  height: _boxHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.x1_5,
                    children: [
                      if (canAdd)
                        AppIcon(AppIcons.add, color: colors.labelNeutral),
                      Text(
                        '아직 셋리스트가 없어요.',
                        style: textStyles.body1Medium.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma `Top` 오른쪽 글자 버튼 (편집·완료). 누르는 높이는 아이콘 버튼과 같게 둔다.
class _TopBarTextButton extends StatelessWidget {
  const _TopBarTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  static const _touchHeight = 44.0; // Figma: Top SuffixIcon 칸 높이

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          height: _touchHeight,
          child: Padding(
            // 상단 바 여백 6과 더해 Figma 오른쪽 여백 16이 된다.
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2_5),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: context.textStyles.body1SemiBold.copyWith(
                  color: enabled ? colors.labelNormal : colors.labelDisable,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
