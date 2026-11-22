import type { ReactNode } from 'react';
import styles from './Tag.module.css';

/** 네모 태그 모양 (Figma TagSquare `Property`): neutral = Default, filled = Fill, outlined = Outline */
export type TagStyle = 'neutral' | 'filled' | 'outlined';

/** 네모 태그 크기 (Figma TagSquare `Size`): small = XS, medium = S, large = XL */
export type TagSize = 'small' | 'medium' | 'large';

/** 둥근 태그 크기 (Figma TagRound `Size`): small = M, medium = L, large = XL */
export type RoundTagSize = 'small' | 'medium' | 'large';

/** Figma `TagSquare`. 누를 수 없는 상태 라벨 (예: 준비 중, 모집 중) */
export function Tag({
  tagStyle = 'neutral',
  size = 'small',
  children,
}: {
  tagStyle?: TagStyle;
  size?: TagSize;
  children: ReactNode;
}) {
  return (
    <span className={[styles.square, styles[tagStyle], styles[size]].join(' ')}>{children}</span>
  );
}

/** Figma `TagRound`. 양끝이 둥근 회색 라벨 */
export function RoundTag({
  size = 'large',
  children,
}: {
  size?: RoundTagSize;
  children: ReactNode;
}) {
  const sizeClass = {
    small: styles.roundSmall,
    medium: styles.roundMedium,
    large: styles.roundLarge,
  }[size];
  return <span className={[styles.round, sizeClass].join(' ')}>{children}</span>;
}
