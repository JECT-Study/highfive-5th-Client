import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma 디자인 시스템 Icon 컴포넌트 (`와이어프레임 New` → Icon → IconList24).
/// 파일은 `assets/icons/`, 이름은 Figma 컴포넌트 이름을 따른다. 쓸 때 하나씩 추가한다.
enum AppIcons {
  home('assets/icons/home.svg'), // Icon: home
  search('assets/icons/search.svg'), // search
  message('assets/icons/message.svg'), // message
  my('assets/icons/my.svg'); // Icon:my

  const AppIcons(this.asset);

  final String asset;
}

/// SVG 아이콘. 색은 [color], 없으면 주변 `IconTheme` 색으로 칠한다(선·면 모두).
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, this.color});

  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      icon.asset,
      width: size,
      height: size,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
