import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_icon.dart';
import '../app_tag.dart';

/// Figma `DetailList` (qr). 예매자 목록 한 줄: 이름·전화번호, 매수·팀 같은 설명, 남은 인원 태그, 오른쪽 화살표.
class QrDetailRow extends StatelessWidget {
  const QrDetailRow({
    super.key,
    required this.name,
    required this.phone,
    required this.detail,
    this.tagLabel,
    this.onTap,
  });

  static const _arrowSize = 20.0; // Figma: arrow 20

  final String name;
  final String phone;

  /// 이름 아래 회색 글자 (예: 2매 | 소음공장).
  final String detail;

  /// 오른쪽 진한 태그 (예: 남은 2명). 없으면 숨긴다.
  final String? tagLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final primary = textStyles.body1Medium.copyWith(color: colors.labelNormal);
    final tagLabel = this.tagLabel;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x5,
            vertical: AppSpacing.x4,
          ),
          child: Row(
            spacing: AppSpacing.x2_5,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.x1,
                  children: [
                    // 이름과 전화번호를 한 줄로 잇는다. 폭이 모자라면 줄 끝에서 줄임표로 자른다.
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: name),
                          const WidgetSpan(
                            child: SizedBox(width: AppSpacing.x2_5),
                          ),
                          TextSpan(text: phone),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: primary,
                    ),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.caption1Regular.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                  ],
                ),
              ),
              if (tagLabel != null)
                AppTag(
                  label: tagLabel,
                  style: AppTagStyle.filled,
                  size: AppTagSize.medium,
                ),
              // Figma: 왼쪽 화살표를 180도 돌린 오른쪽 화살표.
              Transform.flip(
                flipX: true,
                child: AppIcon(
                  AppIcons.chevronLeft,
                  size: _arrowSize,
                  color: colors.labelAlternative,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
