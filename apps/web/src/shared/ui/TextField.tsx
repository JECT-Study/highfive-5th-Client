import type { InputHTMLAttributes, ReactNode } from 'react';
import styles from './TextField.module.css';

type TextFieldProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'prefix'> & {
  /** 테두리를 오류 색으로 바꾸고 aria-invalid를 단다. 오류 문구는 화면이 입력창 아래에 따로 둔다 */
  invalid?: boolean;
  /** 입력칸 앞 (Figma 검색 아이콘) */
  prefix?: ReactNode;
  /** 입력칸 뒤 (Figma `>`, 지우기 버튼, `원`·`장` 같은 단위) */
  suffix?: ReactNode;
};

/**
 * Figma `Input` 공통 입력창.
 * Weak(안내 문구)와 Fill(입력한 값)은 입력 여부로 자동으로 바뀐다. Disabled는 `disabled`, Error는 `invalid`.
 */
export function TextField({ invalid = false, prefix, suffix, className, ...rest }: TextFieldProps) {
  const classes = [styles.field, invalid && styles.invalid, rest.disabled && styles.disabled]
    .filter(Boolean)
    .join(' ');

  return (
    <div className={classes}>
      {prefix && <span className={styles.slot}>{prefix}</span>}
      <input
        {...rest}
        className={[styles.input, className].filter(Boolean).join(' ')}
        aria-invalid={invalid || undefined}
      />
      {suffix && <span className={styles.slot}>{suffix}</span>}
    </div>
  );
}
