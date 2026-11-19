import type { ButtonHTMLAttributes } from 'react';
import styles from './Chip.module.css';

type ChipProps = Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'aria-pressed'> & {
  selected: boolean;
};

/**
 * Figma `Chip` 선택형 버튼. 선택 전은 흰 바탕 + 테두리, 선택 후는 진한 바탕 + 흰 글자.
 * 하나만·여러 개 고르기 규칙은 화면이 정하고, 이 컴포넌트는 `selected`를 aria-pressed로 보여준다.
 * 누를 수 없는 상태 표시는 Chip이 아니라 `Tag`를 쓴다.
 */
export function Chip({ selected, type = 'button', className, ...rest }: ChipProps) {
  return (
    <button
      {...rest}
      type={type}
      aria-pressed={selected}
      className={[styles.chip, selected && styles.selected, className].filter(Boolean).join(' ')}
    />
  );
}
