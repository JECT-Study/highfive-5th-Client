import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app_button.dart';
import '../app_form_section.dart';

/// Figma `InputImg` (show). 폼에서 이미지 한 장(공연 포스터 등)을 고르는 칸: 제목, 점선 상자, 안내 문구.
///
/// [image]가 없으면 점선 상자에 아이콘과 [placeholder]를 보이고(Figma `Default`),
/// 있으면 왼쪽에 작은 미리보기와 오른쪽에 [changeLabel] 버튼을 둔다(Figma `수정`).
/// 사진 고르기는 쓰는 쪽이 [onTap]으로 처리한다. 상자·미리보기·버튼 모두 [onTap]을 부른다.
class ImageInput extends StatelessWidget {
  const ImageInput({
    super.key,
    required this.title,
    required this.placeholder,
    required this.changeLabel,
    required this.onTap,
    this.helperText,
    this.image,
  });

  static const _boxHeight = 100.0; // Figma: Input 높이
  static const _iconSize = 24.0; // Figma: 이미지 아이콘
  static const _previewWidth = 120.0; // Figma: 수정 variant의 미리보기 폭

  final String title;

  /// 이미지가 없을 때 상자 안 문구 (예: 포스터 이미지 추가).
  final String placeholder;

  /// 상자 아래 회색 안내 문구.
  final String? helperText;
  final ImageProvider? image;
  final VoidCallback? onTap;

  /// 이미지가 있을 때 미리보기 옆 버튼 글자 (예: 사진 변경).
  final String changeLabel;

  @override
  Widget build(BuildContext context) {
    final helperText = this.helperText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.x2_5,
      children: [
        AppFormSection(title: title, children: [_box(context)]),
        if (helperText != null)
          Text(
            helperText,
            style: context.textStyles.caption1Regular.copyWith(
              color: context.colors.labelAlternative,
            ),
          ),
      ],
    );
  }

  Widget _box(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.md);
    final image = this.image;

    if (image == null) {
      return Semantics(
        button: true,
        enabled: onTap != null,
        child: Material(
          color: colors.backgroundNormal,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: CustomPaint(
              foregroundPainter: _DashedBorderPainter(color: colors.lineStrong),
              child: SizedBox(
                height: _boxHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3_5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.x1_5,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: _iconSize,
                        color: colors.labelAlternative,
                      ),
                      Text(
                        placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.textStyles.body1Regular.copyWith(
                          color: colors.labelAlternative,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Figma `수정`: 미리보기(뜨기 전에는 회색) + weak small 버튼.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.x2_5,
      children: [
        Semantics(
          button: true,
          enabled: onTap != null,
          label: title,
          child: SizedBox(
            width: _previewWidth,
            height: _boxHeight,
            child: Material(
              color: colors.fillStrong,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Ink.image(
                image: image,
                fit: BoxFit.cover,
                child: InkWell(onTap: onTap),
              ),
            ),
          ),
        ),
        AppButton(
          label: changeLabel,
          onPressed: onTap,
          variant: AppButtonVariant.weak,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}

/// Figma `border-dashed` 테두리. Flutter 테두리에는 점선이 없어 직접 그린다.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  static const _strokeWidth = 1.0; // Figma: border 1
  static const _dash = 2.0; // Figma 그림에서 잰 점선: 2 칠하고 2 띄움
  static const _gap = 2.0;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final border = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_strokeWidth / 2),
          const Radius.circular(AppRadius.md),
        ),
      );
    for (final metric in border.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
