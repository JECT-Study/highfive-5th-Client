import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../models/lineup.dart';
import '../view_models/lineup_view_models.dart';
import 'lineup_formats.dart';
import 'song_row.dart';

/// 셋리스트 편집의 곡 추가 시트를 띄운다 (Figma `라인업-곡추가` 2217:124203).
///
/// 고른 곡은 [onAdd]로 화면의 편집 목록 끝에 바로 붙는다. 서버 저장은 편집의 "완료" 때 한 번이다 (명세 1.8).
/// [addedTrackIds]는 편집 목록에 이미 있는 검색 곡이다. 그 곡은 "추가됨"으로 보인다.
Future<void> showSongAddSheet(
  BuildContext context, {
  required Set<String> addedTrackIds,
  required ValueChanged<LineupSong> onAdd,
}) => showAppBottomSheet<void>(
  context,
  builder: (context) => Flexible(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: SongAddSheet(
          key: SongAddSheet.sheetKey,
          addedTrackIds: addedTrackIds,
          onAdd: onAdd,
        ),
      ),
    ),
  ),
);

/// 곡 추가 시트 내용: 검색창 → 검색 결과("추가") → "직접 입력한 곡 추가".
///
/// 검색은 키보드의 검색 동작으로만 한다. 한글 조합 중인 글자로 음악 검색(외부 API)을 여러 번 부르지 않기 위해서다.
/// 검색창의 글자는 자작곡 제목으로도 쓴다 (검색이 안 되는 503에서도 직접 입력으로 넣을 수 있다).
class SongAddSheet extends ConsumerStatefulWidget {
  const SongAddSheet({
    super.key,
    required this.addedTrackIds,
    required this.onAdd,
  });

  static const sheetKey = ValueKey('songAdd_sheet');
  static const queryKey = ValueKey('songAdd_query');
  static const loadingKey = ValueKey('songAdd_loading');
  static const errorKey = ValueKey('songAdd_error');
  static const noResultKey = ValueKey('songAdd_noResult');
  static const originalKey = ValueKey('songAdd_original');
  static ValueKey<String> resultKey(int index) =>
      ValueKey('songAdd_result_$index');
  static ValueKey<String> resultAddKey(int index) =>
      ValueKey('songAdd_resultAdd_$index');

  final Set<String> addedTrackIds;
  final ValueChanged<LineupSong> onAdd;

  @override
  ConsumerState<SongAddSheet> createState() => _SongAddSheetState();
}

class _SongAddSheetState extends ConsumerState<SongAddSheet> {
  final _query = TextEditingController();

  /// 편집 목록에 있는 검색 곡. 이 시트에서 넣은 곡도 더한다.
  late final Set<String> _added = {...widget.addedTrackIds};

  /// 마지막으로 검색한 말. 비어 있으면 아직 검색하지 않았다.
  String _keyword = '';

  static const _keywordMaxLength = 50; // 명세 1.9: keyword 최대 50자
  static const _titleMaxLength = 100; // 명세 1.8: songTitle 최대 100자
  static const _resultsMaxHeight = 236.0; // Figma: 결과 4줄(59 × 4)까지 보이고 나머지는 스크롤

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String text) {
    // 50자를 넘는 검색어는 서버가 거절하므로 앞 50자로 찾는다.
    final keyword = String.fromCharCodes(
      text.trim().runes.take(_keywordMaxLength),
    );
    if (keyword.isEmpty) return;
    if (keyword == _keyword) {
      // 같은 말을 다시 찾으면(실패 뒤 다시 찾기 포함) 새로 받는다.
      ref.invalidate(songSearchProvider(keyword));
      return;
    }
    setState(() => _keyword = keyword);
  }

  void _addSearched(LineupSong song) {
    widget.onAdd(song);
    final trackId = song.trackId;
    if (trackId != null) setState(() => _added.add(trackId));
  }

  /// 자작곡을 넣고 시트를 닫는다. 편집 목록 맨 아래에서 바로 확인할 수 있다.
  /// 제목은 누른 순간의 검색창 글자다 (버튼을 마지막으로 그린 뒤 바뀐 입력도 반영한다).
  void _addOriginal() {
    final title = _originalTitle(_query.text);
    if (title == null) return;
    widget.onAdd(LineupSong(type: SongType.original, songTitle: title));
    Navigator.of(context).pop();
  }

  /// 검색창 글자를 자작곡 제목으로 쓸 수 있으면 그 제목, 아니면 null (비었거나 100자 초과).
  static String? _originalTitle(String text) {
    final title = text.trim();
    if (title.isEmpty || title.runes.length > _titleMaxLength) return null;
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x4,
      children: [
        const AppModalHeader(title: '곡 추가', centered: true),
        AppTextField(
          key: SongAddSheet.queryKey,
          controller: _query,
          prefix: AppIcon(AppIcons.search, color: colors.labelNormal),
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
        ),
        Text(
          '곡 제목이나 아티스트로 검색해요.',
          style: context.textStyles.body1Regular.copyWith(
            color: colors.labelNeutral,
          ),
        ),
        if (_keyword.isNotEmpty) _results(context),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _query,
          builder: (context, value, _) => AppButton(
            key: SongAddSheet.originalKey,
            label: '직접 입력한 곡 추가',
            variant: AppButtonVariant.weak,
            onPressed: _originalTitle(value.text) == null ? null : _addOriginal,
          ),
        ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final results = ref.watch(songSearchProvider(_keyword));
    final songs = results.value;
    if (results.hasError && !results.isLoading) {
      return _SearchNotice(
        key: SongAddSheet.errorKey,
        message: failureMessage(results.error, '곡을 찾지 못했어요. 다시 검색해 주세요.'),
      );
    }
    if (songs == null) {
      return Center(
        key: SongAddSheet.loadingKey,
        child: CircularProgressIndicator(color: context.colors.labelAssistive),
      );
    }
    if (songs.isEmpty) {
      return const _SearchNotice(
        key: SongAddSheet.noResultKey,
        message: '검색 결과가 없어요.',
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _resultsMaxHeight),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          final trackId = song.trackId;
          final duration = song.durationSeconds;
          return SongRow(
            key: SongAddSheet.resultKey(index),
            padding: const EdgeInsets.all(AppSpacing.x2_5),
            title: song.songTitle,
            subtitle: [
              ?song.artist,
              if (duration != null) formatDuration(duration),
            ].join(' | '),
            imageUrl: song.albumImageUrl,
            trailing: _AddTag(
              key: SongAddSheet.resultAddKey(index),
              added: trackId != null && _added.contains(trackId),
              onTap: () => _addSearched(song),
            ),
          );
        },
      ),
    );
  }
}

/// 검색 결과 대신 보이는 한 줄 안내 (결과 없음, 검색 실패).
class _SearchNotice extends StatelessWidget {
  const _SearchNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: context.textStyles.body1Regular.copyWith(
        color: context.colors.labelAlternative,
      ),
    );
  }
}

/// "추가"·"추가됨" (Figma `TagSquare` XS를 버튼으로 씀).
///
/// 공통 `AppTag`보다 글자(12)·여백(6·12)이 커서 여기서 그린다. 다크 시안의 보라(추가)·회색(추가됨)은
/// 밝은 테마에서 라인업 "주최" 태그와 같은 진한 태그 · 회색 태그로 옮겼다.
/// "추가됨"은 포함 여부만 알린다. 같은 검색 곡도 반복 연주할 수 있다.
class _AddTag extends StatelessWidget {
  const _AddTag({super.key, required this.added, required this.onTap});

  final bool added;
  final VoidCallback onTap;

  static const _touchHeight = 44.0; // 누르는 높이 (시안 태그 29보다 크게)

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground) = added
        ? (colors.fillStrong, colors.labelAssistive)
        : (colors.labelNormal, colors.staticWhite);
    final label = added ? '추가됨' : '추가';
    return Semantics(
      button: true,
      label: added ? '한 번 더 추가' : label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: _touchHeight,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x1_5,
                ),
                child: Text(
                  label,
                  style: context.textStyles.caption1Medium.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
