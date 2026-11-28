import { useId, type InputHTMLAttributes, type ReactNode } from 'react';
import styles from './TextField.module.css';

type TextFieldProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'prefix'> & {
  /** 테두리를 오류 색으로 바꾸고 aria-invalid를 단다. 오류 문구는 화면이 입력창 아래에 따로 둔다 */
  invalid?: boolean;
  /** 입력칸 앞 (Figma 검색 아이콘) */
  prefix?: ReactNode;
  /** 입력칸 뒤 (Figma `>`, 지우기 버튼, `원`·`장` 같은 단위) */
  suffix?: ReactNode;
  /** V3 Fill/서브텍스트. 입력값 아래, 테두리 안에 놓는 보조행 */
  readonly subtext?: string;
  /** search는 V3 2Fill. 검색·삭제 아이콘과 동작은 prefix/suffix로 전달한다 */
  readonly variant?: 'standard' | 'search';
};

/**
 * Figma `Input` 공통 입력창.
 * Weak(안내 문구)와 Fill(입력한 값)은 입력 여부로 자동으로 바뀐다. Disabled는 `disabled`, Error는 `invalid`.
 */
export function TextField({
  invalid = false,
  prefix,
  suffix,
  subtext,
  variant = 'standard',
  className,
  ...rest
}: TextFieldProps) {
  const subtextId = useId();
  const hasSubtext = subtext !== undefined;
  const classes = [
    styles.field,
    invalid && styles.invalid,
    rest.disabled && styles.disabled,
    hasSubtext && styles.withSubtext,
    variant === 'search' && styles.search,
  ]
    .filter(Boolean)
    .join(' ');
  const describedBy =
    [rest['aria-describedby'], hasSubtext && subtextId].filter(Boolean).join(' ') || undefined;
  const input = (
    <input
      {...rest}
      className={[styles.input, className].filter(Boolean).join(' ')}
      aria-invalid={invalid || undefined}
      aria-describedby={describedBy}
    />
  );

  return (
    <div className={classes}>
      {prefix && <span className={styles.slot}>{prefix}</span>}
      {hasSubtext ? (
        <div className={styles.valueGroup}>
          {input}
          <span id={subtextId} className={styles.subtext}>
            {subtext}
          </span>
        </div>
      ) : (
        input
      )}
      {suffix && <span className={styles.slot}>{suffix}</span>}
    </div>
  );
}
