import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `Top`(Default). 화면 상단 바: 왼쪽·오른쪽 [AppIconButton], 가운데 제목.
/// 채팅방·합동공연처럼 내용이 다른 상단 바는 기능 위젯에서 이 크기 토큰으로 만든다.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.title, this.leading, this.trailing});

  final String? title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(AppTopBarTokens.height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.backgroundNormal,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppTopBarTokens.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTopBarTokens.paddingX,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTopBarTokens.iconButtonSize,
                    ),
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.title2Bold.copyWith(
                        color: colors.labelNormal,
                      ),
                    ),
                  ),
                Row(children: [?leading, const Spacer(), ?trailing]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `IconButton`. 아이콘 24, 누르는 영역 44. 접근성을 위해 [tooltip](읽히는 이름)을 꼭 준다.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: icon,
      iconSize: AppTopBarTokens.iconSize,
      color: context.colors.labelNormal,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: AppTopBarTokens.iconButtonSize,
        height: AppTopBarTokens.iconButtonSize,
      ),
    );
  }
}
