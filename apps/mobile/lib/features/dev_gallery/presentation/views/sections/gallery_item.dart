import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/theme/app_typography.dart';

/// 컴포넌트 모음의 항목 하나. 제목은 코드 이름, 그 아래에 Figma 컴포넌트 이름(과 웹 컴포넌트 이름).
class GalleryItem extends StatelessWidget {
  const GalleryItem({
    super.key,
    required this.code,
    required this.figma,
    required this.child,
    this.web,
  });

  final String code;
  final String figma;
  final String? web;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final names = web == null ? 'Figma: $figma' : 'Figma: $figma  ·  웹: $web';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.x3,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x1,
            children: [
              Text(code, style: context.textStyles.title2Bold),
              GalleryCaption(names),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// 항목 안의 작은 설명 (Figma 속성 이름 등).
class GalleryCaption extends StatelessWidget {
  const GalleryCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textStyles.caption1Regular.copyWith(
        color: context.colors.labelAlternative,
      ),
    );
  }
}

/// 폴더(영역) 제목. `shared/widgets/<폴더>/`와 Figma 섹션 이름을 보여준다.
class GalleryFolderHeader extends StatelessWidget {
  const GalleryFolderHeader({
    super.key,
    required this.folder,
    required this.figmaSection,
  });

  final String folder;
  final String figmaSection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.backgroundAlternative,
          border: Border(
            left: BorderSide(
              color: context.colors.labelStrong,
              width: AppSpacing.x1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x1,
            children: [
              Text(folder, style: context.textStyles.title1Bold),
              GalleryCaption('Figma 섹션: $figmaSection'),
            ],
          ),
        ),
      ),
    );
  }
}
