import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma Icon 컴포넌트 (`와이어프레임 New/컴포넌트` → Icon → IconList24 · IconList20 등).
/// 파일은 `assets/icons/`. 주석은 Figma 레이어 이름이다. 이름 뒤 숫자(add20)는 20 크기 목록의 아이콘.
/// Figma에서 여러 조각으로 그려진 아이콘(menu, bell, lock, camera 등)은 아직 없다. 쓸 때 Figma에서 SVG로 내보내 추가한다.
enum AppIcons {
  home('assets/icons/home.svg'), // Icon: home
  search('assets/icons/search.svg'), // search
  message('assets/icons/message.svg'), // message
  my('assets/icons/my.svg'), // Icon:my
  chevronDown('assets/icons/chevron_down.svg'), // Dropdown (18)
  check('assets/icons/check.svg'), // Checkbox 안의 체크 (14)
  location('assets/icons/location.svg'), // 위치 핀 (LocationList)
  exclamation(
    'assets/icons/exclamation.svg',
  ), // emojione-v1:white-exclamation-mark
  trashBin('assets/icons/trash_bin.svg'), // Icon: trash-bin-outline
  sendFill('assets/icons/send_fill.svg'), // Send
  personOut('assets/icons/person_out.svg'), // Icon:personOut
  personSetting('assets/icons/person_setting.svg'), // Icon:person
  more('assets/icons/more.svg'), // more
  close('assets/icons/close.svg'), // Cancle
  send('assets/icons/send.svg'), // Icon:send
  settings('assets/icons/settings.svg'), // icons:settings
  arrowBack('assets/icons/arrow_back.svg'), // arrow
  ticket('assets/icons/ticket.svg'), // ticket
  add('assets/icons/add.svg'), // add24
  share('assets/icons/share.svg'), // share
  closeCircle(
    'assets/icons/close_circle.svg',
    keepsOwnColors: true,
  ), // close (20)
  checkCircle(
    'assets/icons/check_circle.svg',
    keepsOwnColors: true,
  ), // check (20)
  add20('assets/icons/add_20.svg'), // add20 (20)
  deleteFill('assets/icons/delete_fill.svg'), // DeleteFill (20)
  megaphone('assets/icons/megaphone.svg'), // Megaphone (20)
  trash('assets/icons/trash.svg'), // Trash (20)
  write('assets/icons/write.svg'), // Write (20)
  pin('assets/icons/pin.svg'), // Pin (20)
  chevronLeft('assets/icons/chevron_left.svg'), // Icon:arrow (16)
  checkCircleLarge('assets/icons/check_circle_large.svg'); // Icon60Check (60)

  const AppIcons(this.asset, {this.keepsOwnColors = false});

  final String asset;

  /// 두 가지 색으로 그려진 아이콘(검은 원 + 흰 표시). 한 색으로 칠하면 모양이 사라지므로 원래 색 그대로 그린다.
  final bool keepsOwnColors;
}

/// SVG 아이콘. 색은 [color], 없으면 주변 `IconTheme` 색으로 칠한다(선·면 모두).
/// [AppIcons.keepsOwnColors]인 아이콘은 칠하지 않는다.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, this.color});

  final AppIcons icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = icon.keepsOwnColors
        ? null
        : color ?? IconTheme.of(context).color;
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
