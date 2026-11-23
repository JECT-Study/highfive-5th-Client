import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Figma `Badge`·`Profile` (공연페이지). 라인업에 참여한 팀을 동그란 사진과 이름으로 보인다.
///
/// - 팀: 사진(없으면 회색 원), [hostLabel]이 있으면 오른쪽 위에 진한 배지(예: 주최).
/// - [recruiting]: 아직 빈자리. 점선 원과 흐린 이름(예: 모집 중).
/// - [name]이 없으면 원만 보인다 (Figma `Badge`), 있으면 원 아래에 이름을 둔다 (Figma `Profile`).
class ShowTeamAvatar extends StatelessWidget {
  const ShowTeamAvatar({
    super.key,
    this.name,
    this.image,
    this.hostLabel,
    this.recruiting = false,
  });

  final String? name;
  final ImageProvider? image;

  /// 사진 오른쪽 위 배지 글자. [recruiting]이면 보이지 않는다.
  final String? hostLabel;
  final bool recruiting;

  static const _size = 48.0; // Figma: Badge 원 지름
  static const _badgeLeft = 27.0; // Figma: 배지 왼쪽 위치 (원 밖으로 조금 나간다)

  @override
  Widget build(BuildContext context) {
    final name = this.name;
    final avatar = _avatar(context);
    if (name == null) return avatar;
    final colors = context.colors;
    return SizedBox(
      width: _size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.x1_5,
        children: [
          avatar,
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            // Figma: 팀 #545456 · 모집 중 #858586 → 가장 가까운 의미 색.
            style: context.textStyles.caption1Medium.copyWith(
              color: recruiting ? colors.labelAlternative : colors.labelNeutral,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    final colors = context.colors;
    final hostLabel = recruiting ? null : this.hostLabel;
    final image = this.image;
    final circle = recruiting
        ? CustomPaint(
            size: const Size.square(_size),
            painter: _DashedCirclePainter(color: colors.labelAlternative),
          )
        : Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.fillStrong,
              image: image == null
                  ? null
                  : DecorationImage(image: image, fit: BoxFit.cover),
            ),
          );
    if (hostLabel == null) return circle;
    return SizedBox.square(
      dimension: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            left: _badgeLeft,
            top: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.gray800,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x1_5,
                  vertical: AppSpacing.x1,
                ),
                child: Text(
                  hostLabel,
                  style: context.textStyles.tag1.copyWith(
                    color: colors.staticWhite,
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

/// Figma `border-dashed` 1px 원. Flutter 테두리에는 점선이 없어 직접 그린다.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  static const _strokeWidth = 1.0; // Figma: border 1px
  static const _dash = 3.0; // Figma 그림에서 잰 점선 한 칸
  static const _gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;
    final circle = Path()
      ..addOval(
        Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      );
    for (final metric in circle.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(metric.extractPath(start, start + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
