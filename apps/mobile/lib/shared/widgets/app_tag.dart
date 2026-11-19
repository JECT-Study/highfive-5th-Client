import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// 네모 태그 모양 (Figma TagSquare `Property`).
/// neutral = 회색 바탕(Default), filled = 진한 바탕(Fill), outlined = 테두리(Outline).
enum AppTagStyle { neutral, filled, outlined }

/// 네모 태그 크기 (Figma TagSquare `Size`): small = XS, medium = S, large = XL.
enum AppTagSize { small, medium, large }

/// 둥근 태그 크기 (Figma TagRound `Size`): small = M, medium = L, large = XL.
enum AppRoundTagSize { small, medium, large }

/// Figma `TagSquare`. 누를 수 없는 상태 라벨 (예: 준비 중, 모집 중).
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.style = AppTagStyle.neutral,
    this.size = AppTagSize.small,
  });

  final String label;
  final AppTagStyle style;
  final AppTagSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final (background, foreground, border) = switch (style) {
      AppTagStyle.neutral => (colors.fillStrong, colors.labelNormal, null),
      AppTagStyle.filled => (colors.labelNormal, colors.staticWhite, null),
      AppTagStyle.outlined => (
        colors.backgroundNormal,
        colors.labelNormal,
        colors.labelNormal,
      ),
    };
    final text = switch (size) {
      AppTagSize.small => textStyles.tag2,
      AppTagSize.medium => textStyles.tag1,
      AppTagSize.large => textStyles.caption1Regular,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: border == null ? null : Border.all(color: border),
        borderRadius: BorderRadius.circular(AppTagTokens.squareRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTagTokens.squarePaddingX,
          vertical: AppTagTokens.squarePaddingY,
        ),
        child: Text(
          label,
          style: text.copyWith(color: foreground),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Figma `TagRound`. 양끝이 둥근 회색 라벨.
class AppRoundTag extends StatelessWidget {
  const AppRoundTag({
    super.key,
    required this.label,
    this.size = AppRoundTagSize.large,
  });

  final String label;
  final AppRoundTagSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final (padding, text, foreground) = switch (size) {
      AppRoundTagSize.small => (
        const EdgeInsets.all(AppTagTokens.roundSmallPadding),
        textStyles.tag2,
        colors.labelNeutral,
      ),
      AppRoundTagSize.medium => (
        const EdgeInsets.symmetric(
          horizontal: AppTagTokens.roundMediumPaddingX,
          vertical: AppTagTokens.roundMediumPaddingY,
        ),
        textStyles.caption1SemiBold,
        colors.labelStrong,
      ),
      AppRoundTagSize.large => (
        const EdgeInsets.symmetric(
          horizontal: AppTagTokens.roundLargePaddingX,
          vertical: AppTagTokens.roundLargePaddingY,
        ),
        textStyles.body1Medium,
        colors.labelNormal,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.fillStrong,
        borderRadius: BorderRadius.circular(AppTagTokens.roundRadius),
      ),
      child: Padding(
        padding: padding,
        child: Text(label, style: text.copyWith(color: foreground)),
      ),
    );
  }
}
