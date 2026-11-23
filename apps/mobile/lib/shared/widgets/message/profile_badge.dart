import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../app_badge.dart';

/// Figma `Badge` (메시지). 프로필 사진과 오른쪽 위 안 읽은 메시지 수.
///
/// [count]가 0 이하면 숫자 동그라미를 숨긴다 (Figma badge = false).
/// 숫자 동그라미는 사진 오른쪽 밖으로 조금 나오지만 위젯 크기는 사진 크기 그대로라, 목록에서 옆 글자가 밀리지 않는다.
class ProfileBadge extends StatelessWidget {
  const ProfileBadge({super.key, this.image, this.count = 0});

  static const _imageSize = 48.0; // Figma: 프로필 이미지
  static const _badgeOverhang = 5.0; // Figma: 숫자 동그라미가 사진 밖으로 나온 폭 (53 - 48)

  /// 프로필 사진. null이면 회색 원을 그린다.
  final ImageProvider? image;

  /// 안 읽은 메시지 수.
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _imageSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: _imageSize / 2,
            backgroundColor: context.colors.fillStrong,
            backgroundImage: image,
          ),
          if (count > 0)
            Positioned(
              top: 0,
              right: -_badgeOverhang,
              child: AppBadge(count: count),
            ),
        ],
      ),
    );
  }
}
