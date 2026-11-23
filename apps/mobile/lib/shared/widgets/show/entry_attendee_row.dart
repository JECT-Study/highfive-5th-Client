import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_icon.dart';
import '../app_top_bar.dart';
import 'show_meta_text.dart';

/// Figma `이름으로 찾기` (공연페이지 · 현장 입장). 이름으로 찾은 신청자 한 명:
/// 이름·연락처, 아래에 매수·팀 같은 정보, 오른쪽에 입장 버튼과 자세히 보기 화살표.
///
/// 입장 처리는 쓰는 쪽이 [onEnter]로 처리한다 (쓰기 명령이라 ViewModel 메서드로 연결한다).
class EntryAttendeeRow extends StatelessWidget {
  const EntryAttendeeRow({
    super.key,
    required this.name,
    required this.enterLabel,
    required this.onEnter,
    required this.detailTooltip,
    required this.onDetail,
    this.phone,
    this.details = const [],
  });

  final String name;

  /// 이름 옆 연락처 (예: 010-8888-1234).
  final String? phone;

  /// 아래 줄 점 구분 정보 (예: 2매, 소음공장).
  final List<String> details;

  /// 입장 버튼 글자 (예: 2명).
  final String enterLabel;
  final VoidCallback? onEnter;

  /// 화살표 버튼의 읽히는 이름 (예: 신청 자세히 보기).
  final String detailTooltip;
  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nameStyle = context.textStyles.title2SemiBold.copyWith(
      color: colors.labelNormal,
    );
    final phone = this.phone;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lineNeutral)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.x1,
          bottom: AppSpacing.x2_5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.x2,
          children: [
            Row(
              spacing: AppSpacing.x1_5,
              children: [
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: nameStyle,
                  ),
                ),
                if (phone != null) Text(phone, maxLines: 1, style: nameStyle),
              ],
            ),
            Row(
              children: [
                Expanded(child: ShowMetaText(details)),
                AppButton(
                  label: enterLabel,
                  onPressed: onEnter,
                  size: AppButtonSize.small,
                ),
                AppIconButton(
                  // Figma `arrow`를 오른쪽 방향으로 놓는다.
                  icon: Transform.flip(
                    flipX: true,
                    child: const AppIcon(AppIcons.arrowBack),
                  ),
                  tooltip: detailTooltip,
                  onPressed: onDetail,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
