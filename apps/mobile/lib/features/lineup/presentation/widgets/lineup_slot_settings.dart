import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/show/show_lineup_item.dart';
import '../../models/lineup.dart';
import 'lineup_formats.dart';

/// 기존 합류 팀을 목표 순서로 옮기는 로컬 선택 초안. 저장 전에는 쓰기 명령을 내지 않는다.
class LineupSlotSettings extends StatefulWidget {
  const LineupSlotSettings({
    super.key,
    required this.teams,
    required this.targetIndex,
  });

  final List<LineupTeam> teams;
  final int targetIndex;

  static const backKey = ValueKey('lineupSlot_back');
  static const pickerKey = ValueKey('lineupSlot_picker');
  static const saveKey = ValueKey('lineupSlot_save');
  static const loadKey = ValueKey('lineupSlot_load');
  static ValueKey<String> optionKey(int bandId) =>
      ValueKey('lineupSlot_option_$bandId');

  @override
  State<LineupSlotSettings> createState() => _LineupSlotSettingsState();
}

class _LineupSlotSettingsState extends State<LineupSlotSettings> {
  LineupTeam? _selected;

  Future<void> _pick() async {
    var draft = _selected;
    final selected = await showModalBottomSheet<LineupTeam>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.colors.backgroundNormal,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.x3,
              children: [
                Text('참여 밴드 불러오기', style: context.textStyles.body1Bold),
                Text(
                  '${widget.targetIndex + 1}번째 순서에 공연할 밴드를 골라주세요.',
                  style: context.textStyles.caption1Medium.copyWith(
                    color: context.colors.labelAlternative,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: AppSpacing.x2,
                      children: [
                        for (final team in widget.teams)
                          Semantics(
                            selected: draft == team,
                            child: _BandRow(
                              key: LineupSlotSettings.optionKey(
                                team.band.bandId,
                              ),
                              team: team,
                              selected: draft == team,
                              onTap: () => update(() => draft = team),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                AppButton(
                  key: LineupSlotSettings.loadKey,
                  label: '불러오기',
                  onPressed: draft == null
                      ? null
                      : () => Navigator.of(context).pop(draft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted && selected != null) setState(() => _selected = selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppTopBar(
        title: '라인업 ${widget.targetIndex + 1}번째',
        leading: AppIconButton(
          key: LineupSlotSettings.backKey,
          icon: const AppIcon(AppIcons.arrowBack),
          tooltip: '취소',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.x5),
        child: AppButton(
          key: LineupSlotSettings.saveKey,
          label: '저장',
          onPressed: selected == null
              ? null
              : () => Navigator.of(context).pop(selected.band.bandId),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x5),
        children: [
          _Panel(
            child: Text(
              '공연 순서  ${widget.targetIndex + 1}번째',
              style: context.textStyles.caption1Medium,
            ),
          ),
          const SizedBox(height: AppSpacing.x5),
          Row(
            children: [
              Expanded(
                child: Text('공연할 밴드', style: context.textStyles.body1Bold),
              ),
              if (selected != null)
                TextButton(
                  key: LineupSlotSettings.pickerKey,
                  onPressed: _pick,
                  child: const Text('변경'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
          if (selected == null)
            _Panel(
              child: TextButton(
                key: LineupSlotSettings.pickerKey,
                onPressed: _pick,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.x4),
                  child: Text('+ \n참여 밴드에서 불러오기', textAlign: TextAlign.center),
                ),
              ),
            )
          else
            ShowLineupItem(
              name: selected.band.name,
              details: [
                genreNames(selected.band.genres),
                '${selected.band.memberCount}명',
              ],
              image: selected.band.profileImageUrl == null
                  ? null
                  : NetworkImage(selected.band.profileImageUrl!),
            ),
          const SizedBox(height: AppSpacing.x5),
          Text('셋리스트', style: context.textStyles.body1Bold),
          const SizedBox(height: AppSpacing.x2),
          _Panel(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x5),
              child: Text(
                selected == null
                    ? '밴드를 먼저 불러와주세요.'
                    : selected.setlistPreview.isEmpty
                    ? '아직 셋리스트가 없어요.'
                    : selected.setlistPreview.join('\n'),
                textAlign: TextAlign.center,
                style: context.textStyles.body1Regular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.x3),
    decoration: BoxDecoration(
      color: context.colors.backgroundAlternative,
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: child,
  );
}

class _BandRow extends StatelessWidget {
  const _BandRow({
    super.key,
    required this.team,
    required this.selected,
    required this.onTap,
  });

  final LineupTeam team;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.backgroundAlternative,
    borderRadius: BorderRadius.circular(AppRadius.md),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Row(
          spacing: AppSpacing.x3,
          children: [
            CircleAvatar(
              backgroundColor: context.colors.fillStrong,
              backgroundImage: team.band.profileImageUrl == null
                  ? null
                  : NetworkImage(team.band.profileImageUrl!),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.band.name,
                    style: context.textStyles.body1Bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${genreNames(team.band.genres)} · ${team.band.memberCount}명',
                    style: context.textStyles.caption1Medium.copyWith(
                      color: context.colors.labelAlternative,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.radio_button_checked,
                color: context.colors.labelNormal,
              ),
          ],
        ),
      ),
    ),
  );
}
