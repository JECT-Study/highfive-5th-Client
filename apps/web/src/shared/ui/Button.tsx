import type { ButtonHTMLAttributes, ReactNode } from 'react';
import styles from './Button.module.css';

/** 버튼의 중요도 (Figma Btn `Color`). fill = 주요 행동, weak = 보조 행동, danger = 되돌릴 수 없는 행동 */
export type ButtonVariant = 'fill' | 'weak' | 'danger';

/** 버튼 크기 (Figma Btn `Property`). large = XL, medium = XS, small = Mini, floating = 떠 있는 대표 행동 */
export type ButtonSize = 'large' | 'medium' | 'small' | 'floating';

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
  /** 글자 앞 아이콘 (Figma PrefixIcon). 색은 버튼 글자색(currentColor)을 쓴다 */
  icon?: ReactNode;
  /** 글자 대신 점 3개를 보이고 눌리지 않는다. 같은 요청을 두 번 보내지 않게 요청 중 상태를 넘긴다 */
  loading?: boolean;
};

/**
 * Figma `Btn` 공통 버튼. 너비는 정하지 않는다. 가로를 채우려면 부모 레이아웃에서 `width: 100%`를 준다.
 * `type` 기본값은 `button`이다 (폼 안에서 의도치 않게 제출하지 않도록).
 */
export function Button({
  variant = 'fill',
  size = 'large',
  icon,
  loading = false,
  disabled,
  type = 'button',
  className,
  children,
  ...rest
}: ButtonProps) {
  const classes = [styles.button, styles[size], styles[variant], className]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      {...rest}
      type={type}
      className={classes}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
    >
      {loading ? (
        <>
          <span className={styles.loader} aria-hidden="true">
            <span className={styles.dot} />
            <span className={styles.dot} />
            <span className={styles.dot} />
          </span>
          <span className={styles.visuallyHidden}>{children}</span>
        </>
      ) : (
        <>
          {icon && (
            <span className={styles.icon} aria-hidden="true">
              {icon}
            </span>
          )}
          <span className={styles.label}>{children}</span>
        </>
      )}
    </button>
  );
}
