import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../../../shared/widgets/show/show_meta_text.dart';
import '../../models/host_band.dart';
import '../providers/concert_creation_providers.dart';

/// Figma `마이페이지-공연추가_밴드선택시트`(2216:138580)를 띄운다.
/// 공연을 만들 밴드(= 주최 팀, 초기 주최 대표자는 그 밴드의 대표자인 나)를 고르면 그 밴드를, 닫으면 null을 돌려준다.
Future<HostBand?> showHostBandPickerSheet(BuildContext context) =>
    showAppBottomSheet<HostBand>(
      context,
      builder: (_) => const HostBandPickerSheet(),
    );

/// 내가 대표자인 밴드 목록에서 하나를 고르는 시트 내용. 밴드가 하나뿐이면 미리 골라 둔다.
class HostBandPickerSheet extends ConsumerStatefulWidget {
  const HostBandPickerSheet({super.key});

  static const nextKey = ValueKey('hostBandPicker_next');
  static const retryKey = ValueKey('hostBandPicker_retry');
  static const loadingKey = ValueKey('hostBandPicker_loading');
  static const emptyKey = ValueKey('hostBandPicker_empty');
  static ValueKey<String> optionKey(int bandId) =>
      ValueKey('hostBandPicker_option_$bandId');

  @override
  ConsumerState<HostBandPickerSheet> createState() =>
      _HostBandPickerSheetState();
}

class _HostBandPickerSheetState extends ConsumerState<HostBandPickerSheet> {
  HostBand? _picked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final message = textStyles.body1Regular.copyWith(
      color: colors.labelNeutral,
    );
    final bands = ref.watch(hostBandsProvider);
    final list = bands.value ?? const <HostBand>[];
    final selected = _picked ?? (list.length == 1 ? list.single : null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x4,
      children: [
        const AppModalHeader(
          title: '어느 밴드로 공연을 만들까요?',
          subtitle: '내가 대표자인 밴드만 보여요.',
        ),
        bands.when(
          loading: () => const Center(
            key: HostBandPickerSheet.loadingKey,
            child: CircularProgressIndicator(),
          ),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.x2,
            children: [
              Text('밴드 목록을 불러오지 못했어요. 다시 시도해 주세요.', style: message),
              AppButton(
                key: HostBandPickerSheet.retryKey,
                label: '다시 시도',
                variant: AppButtonVariant.weak,
                size: AppButtonSize.medium,
                onPressed: () => ref.invalidate(hostBandsProvider),
              ),
            ],
          ),
          data: (options) => options.isEmpty
              ? Text(
                  key: HostBandPickerSheet.emptyKey,
                  '현재 선택할 수 있는 밴드가 없어요.',
                  style: message,
                )
              : Column(
                  spacing: AppSpacing.x2_5,
                  children: [
                    for (final band in options)
                      _HostBandOption(
                        key: HostBandPickerSheet.optionKey(band.id),
                        band: band,
                        selected: band.id == selected?.id,
                        onTap: () => setState(() => _picked = band),
                      ),
                  ],
                ),
        ),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            key: HostBandPickerSheet.nextKey,
            label: '다음',
            onPressed: selected == null
                ? null
                : () => Navigator.of(context).pop(selected),
          ),
        ),
      ],
    );
  }
}

/// Figma `BandOption`: 프로필 원, 밴드 이름, `장르 · 팀원 N명`, 라디오. 고른 밴드만 테두리를 두른다.
class _HostBandOption extends StatelessWidget {
  const _HostBandOption({
    super.key,
    required this.band,
    required this.selected,
    required this.onTap,
  });

  final HostBand band;
  final bool selected;
  final VoidCallback onTap;

  static const _avatarSize = 38.0; // Figma: PrefixIcon 38
  static const _selectedBorderWidth = 2.0; // Figma: 고른 밴드 테두리 2

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.backgroundNormal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: selected
            ? BorderSide(color: colors.labelNormal, width: _selectedBorderWidth)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x2,
            vertical: AppSpacing.x2_5,
          ),
          child: Row(
            spacing: AppSpacing.x2_5,
            children: [
              Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  color: colors.fillStrong,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.x1,
                  children: [
                    Text(
                      band.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.title2SemiBold.copyWith(
                        color: colors.labelNormal,
                      ),
                    ),
                    ShowMetaText([
                      band.genres.map((genre) => genre.label).join(', '),
                      '팀원 ${band.memberCount}명',
                    ]),
                  ],
                ),
              ),
              AppRadio(
                selected: selected,
                onTap: onTap,
                semanticLabel: band.name,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
